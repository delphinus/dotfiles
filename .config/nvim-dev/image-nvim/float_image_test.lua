-- Prototype: display PNG/JPEG/WebP images in a Neovim floating window
-- using Kitty Graphics Protocol with automatic sizing.
--
-- Usage: NVIM_APPNAME=nvim-dev/image-nvim nvim
--        :luafile ~/.config/nvim-dev/image-nvim/float_image_test.lua
--        :ImageTest [path]          (default: sample.png)
--        :ImageTest sample.jpg
--        :ImageTest sample.webp

local uv = vim.uv or vim.loop
local ffi = require("ffi")

local base_dir = vim.fn.expand("~/.config/nvim-dev/image-nvim")
local IMAGE_ID_COUNTER = 30

-- ============================================================================
-- TTY setup
-- ============================================================================

local tty_path = nil
do
  local handle = io.popen("tty 2>/dev/null")
  if handle then
    tty_path = vim.fn.trim(handle:read("*a"))
    handle:close()
    if tty_path == "" or tty_path == "not a tty" then tty_path = nil end
  end
end

local stdout = uv.new_tty(1, false)
if not stdout and not tty_path then error("no tty available") end

---@param data string
local function term_write(data)
  if data == "" then return end
  if tty_path then
    local f = io.open(tty_path, "w")
    if f then
      f:write(data)
      f:close()
      return
    end
  end
  if stdout then stdout:write(data) end
end

local function move_cursor(x, y)
  term_write("\x1b[" .. y .. ";" .. x .. "H")
  uv.sleep(1)
end

-- ============================================================================
-- Terminal cell size detection via TIOCGWINSZ (no external dependency)
-- ============================================================================

ffi.cdef([[
  typedef struct { unsigned short row; unsigned short col; unsigned short xpixel; unsigned short ypixel; } winsize;
  int ioctl(int, unsigned long, ...);
]])

local TIOCGWINSZ = (vim.fn.has("mac") == 1 or vim.fn.has("bsd") == 1) and 0x40087468 or 0x5413

---@return { cell_w: number, cell_h: number }?
local function get_cell_size()
  local sz = ffi.new("winsize")
  if ffi.C.ioctl(1, TIOCGWINSZ, sz) ~= 0 then return nil end
  local xpixel, ypixel = sz.xpixel, sz.ypixel
  if xpixel == 0 or ypixel == 0 then
    xpixel = sz.col * 8
    ypixel = sz.row * 16
  end
  return { cell_w = xpixel / sz.col, cell_h = ypixel / sz.row }
end

-- ============================================================================
-- Image dimension detection from file headers (no external dependency)
-- ============================================================================

--- Read first N bytes of a file
---@param path string
---@param n integer
---@return string?
local function read_header(path, n)
  local f = io.open(path, "rb")
  if not f then return nil end
  local data = f:read(n)
  f:close()
  return data
end

--- Big-endian uint16
local function be16(s, offset)
  return s:byte(offset) * 256 + s:byte(offset + 1)
end

--- Big-endian uint32
local function be32(s, offset)
  return s:byte(offset) * 16777216 + s:byte(offset + 1) * 65536
       + s:byte(offset + 2) * 256 + s:byte(offset + 3)
end

--- Little-endian uint16
local function le16(s, offset)
  return s:byte(offset) + s:byte(offset + 1) * 256
end

--- Little-endian uint24
local function le24(s, offset)
  return s:byte(offset) + s:byte(offset + 1) * 256 + s:byte(offset + 2) * 65536
end

--- Get PNG dimensions from IHDR chunk
---@param path string
---@return integer?, integer?  width, height
local function png_dimensions(path)
  local h = read_header(path, 24)
  if not h or #h < 24 then return nil end
  if h:sub(1, 4) ~= "\137PNG" then return nil end
  return be32(h, 17), be32(h, 21)
end

--- Get JPEG dimensions by scanning for SOF marker
---@param path string
---@return integer?, integer?  width, height
local function jpeg_dimensions(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local data = f:read("*a")
  f:close()
  if not data or #data < 2 then return nil end
  if data:byte(1) ~= 0xFF or data:byte(2) ~= 0xD8 then return nil end

  local pos = 3
  while pos < #data - 1 do
    if data:byte(pos) ~= 0xFF then pos = pos + 1; goto continue end
    local marker = data:byte(pos + 1)
    -- SOF markers: 0xC0-0xCF except 0xC4 (DHT) and 0xC8 (JPG)
    if marker >= 0xC0 and marker <= 0xCF and marker ~= 0xC4 and marker ~= 0xC8 then
      if pos + 9 <= #data then
        -- pos+4: precision (1 byte), pos+5: height (2 bytes), pos+7: width (2 bytes)
        local height = be16(data, pos + 5)
        local width = be16(data, pos + 7)
        return width, height
      end
    end
    -- Skip to next marker using segment length
    if pos + 3 <= #data then
      local seg_len = be16(data, pos + 2)
      pos = pos + 2 + seg_len
    else
      break
    end
    ::continue::
  end
  return nil
end

--- Get WebP dimensions (VP8, VP8L, VP8X variants)
---@param path string
---@return integer?, integer?  width, height
local function webp_dimensions(path)
  local h = read_header(path, 30)
  if not h or #h < 16 then return nil end
  if h:sub(1, 4) ~= "RIFF" or h:sub(9, 12) ~= "WEBP" then return nil end

  local chunk_type = h:sub(13, 16)
  if chunk_type == "VP8 " and #h >= 30 then
    -- Lossy: start code at offset 24 (0x9D 0x01 0x2A), then width/height LE 16-bit
    if h:byte(24) == 0x9D and h:byte(25) == 0x01 and h:byte(26) == 0x2A then
      local w = bit.band(le16(h, 27), 0x3FFF)
      local height = bit.band(le16(h, 29), 0x3FFF)
      return w, height
    end
  elseif chunk_type == "VP8L" and #h >= 26 then
    -- Lossless: signature byte 0x2F at offset 21, then bitpacked w/h
    if h:byte(22) == 0x2F then
      -- 4 bytes at offset 22: 14 bits width-1, 14 bits height-1
      local b = le16(h, 23) + le16(h, 25) * 65536
      local w = bit.band(b, 0x3FFF) + 1
      local height = bit.band(bit.rshift(b, 14), 0x3FFF) + 1
      return w, height
    end
  elseif chunk_type == "VP8X" and #h >= 30 then
    -- Extended: 4 bytes flags at 21, then 3 bytes width-1, 3 bytes height-1
    local w = le24(h, 25) + 1
    local height = le24(h, 28) + 1
    return w, height
  end
  return nil
end

--- Detect image dimensions for PNG, JPEG, or WebP
---@param path string
---@return integer?, integer?  width, height
local function image_dimensions(path)
  local h = read_header(path, 4)
  if not h then return nil end

  if h:sub(1, 4) == "\137PNG" then
    return png_dimensions(path)
  elseif h:byte(1) == 0xFF and h:byte(2) == 0xD8 then
    return jpeg_dimensions(path)
  elseif h:sub(1, 4) == "RIFF" then
    return webp_dimensions(path)
  end
  return nil
end

-- ============================================================================
-- Kitty Graphics Protocol
-- ============================================================================

--- Ensure the image is PNG (convert if JPEG/WebP). Returns path to a PNG file.
--- Uses t=t (temp file) for converted files so the terminal deletes them.
---@param path string  absolute path to image file
---@return string png_path, boolean is_temp
local function ensure_png(path)
  local h = read_header(path, 4)
  if h and h:sub(1, 4) == "\137PNG" then
    return path, false
  end
  -- Convert to temp PNG using magick
  local tmp = os.tmpname() .. ".png"
  local result = vim.system({ "magick", path, "-resize", "2000x2000>", tmp }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("magick convert failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
    return path, false
  end
  return tmp, true
end

--- Build Kitty Graphics Protocol message using file path transmission.
--- Uses t=t for temp files (terminal deletes after reading) or t=f for regular files.
---@param path string  absolute path to PNG file
---@param id integer
---@param cols integer
---@param rows integer
---@param is_temp boolean  if true, use t=t so terminal deletes the file
---@return string message
local function build_kitty_message(path, id, cols, rows, is_temp)
  local b64_path = vim.base64.encode(path)
  local t = is_temp and "t" or "f"
  return string.format(
    "\x1b_Ga=T,f=100,t=%s,i=%d,c=%d,r=%d,C=1;%s\x1b\\",
    t, id, cols, rows, b64_path
  )
end

-- ============================================================================
-- :ImageTest command
-- ============================================================================

vim.api.nvim_create_user_command("ImageTest", function(opts)
  local arg = opts.args ~= "" and opts.args or "sample.png"
  -- Resolve path: absolute or relative to base_dir
  local img_path = vim.fn.expand(arg)
  if img_path:sub(1, 1) ~= "/" then
    img_path = base_dir .. "/" .. img_path
  end

  -- Get image dimensions
  local img_w, img_h = image_dimensions(img_path)
  if not img_w or not img_h then
    vim.notify("Cannot read image dimensions: " .. img_path, vim.log.levels.ERROR)
    return
  end

  -- Get terminal cell size
  local cell = get_cell_size()
  if not cell then
    vim.notify("Cannot detect terminal cell size", vim.log.levels.ERROR)
    return
  end

  -- Calculate display size in cells, maintaining aspect ratio
  local max_cols = 40  -- max width in cells
  local max_rows = 20  -- max height in cells

  local cols = math.ceil(img_w / cell.cell_w)
  local rows = math.ceil(img_h / cell.cell_h)

  -- Scale down to fit within limits
  if cols > max_cols then
    local scale = max_cols / cols
    cols = max_cols
    rows = math.ceil(rows * scale)
  end
  if rows > max_rows then
    local scale = max_rows / rows
    rows = max_rows
    cols = math.ceil(cols * scale)
  end

  -- Convert to PNG if needed (Kitty protocol f=100 requires PNG)
  local png_path, is_temp = ensure_png(img_path)

  IMAGE_ID_COUNTER = IMAGE_ID_COUNTER + 1
  local image_id = IMAGE_ID_COUNTER

  local message = build_kitty_message(png_path, image_id, cols, rows, is_temp)

  -- Build floating window content
  local buf = vim.api.nvim_create_buf(false, true)
  local placeholder = {}
  for _ = 1, rows do
    table.insert(placeholder, "")
  end

  local filename = vim.fn.fnamemodify(img_path, ":t")
  local header = string.format("  %s (%dx%d → %dc×%dr)", filename, img_w, img_h, cols, rows)
  local lines = vim.list_extend({ header, "" }, placeholder)
  table.insert(lines, "")
  table.insert(lines, string.format("  cell: %.0f×%.0fpx", cell.cell_w, cell.cell_h))

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local win_width = math.max(cols + 4, #header + 2, 30)
  local win_height = #lines + 1
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = 1,
    col = math.floor((vim.o.columns - win_width) / 2),
    width = win_width,
    height = win_height,
    style = "minimal",
    border = "rounded",
    title = " Image Test ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_cursor(win, { 3, 0 })
  vim.cmd("redraw!")

  local win_pos = vim.api.nvim_win_get_position(win)
  local screen_row = win_pos[1] + 3
  local screen_col = win_pos[2] + 2

  term_write("\x1b[s")
  move_cursor(screen_col + 1, screen_row + 1)

  term_write(message)

  term_write("\x1b[u")

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      term_write(string.format("\x1b_Ga=d,d=i,i=%d\x1b\\", image_id))
    end,
  })

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf })
  end
end, { nargs = "?" })

vim.notify("Run :ImageTest [path] to show image in floating window", vim.log.levels.INFO)
