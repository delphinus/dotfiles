-- Minimal prototype: display a PNG image inside a Neovim floating window
-- using Kitty Graphics Protocol directly.
--
-- Usage: NVIM_APPNAME=nvim-dev/image-nvim nvim
--        :luafile ~/.config/nvim-dev/image-nvim/float_image_test.lua
--        :ImageTest

local png_path = vim.fn.expand("~/.config/nvim-dev/image-nvim/sample.png")
local IMAGE_ID = 31

local tty = vim.uv.new_tty(1, false)

--- Write a single small chunk synchronously via try_write.
--- Retries if partial write, with a hard limit to avoid infinite loop.
---@param data string
local function sync_write(data)
  local offset = 1
  local attempts = 0
  while offset <= #data and attempts < 100 do
    local written = tty:try_write(data:sub(offset))
    if written and written > 0 then
      offset = offset + written
      attempts = 0
    else
      attempts = attempts + 1
    end
  end
end

--- Build individual Kitty APC messages as separate small strings.
--- Each message is a complete \x1b_G...\x1b\\ sequence.
---@param path string
---@param id integer
---@param cols integer
---@param rows integer
---@return string[]? chunks  list of complete APC messages
local function build_kitty_chunks(path, id, cols, rows)
  local f = io.open(path, "rb")
  if not f then return nil end
  local data = f:read("*a")
  f:close()

  local b64 = vim.base64.encode(data)
  -- Use small chunks so each APC message fits in a single try_write call
  local chunk_size = 512
  local total = #b64
  local messages = {}

  for i = 1, total, chunk_size do
    local chunk = b64:sub(i, i + chunk_size - 1)
    local more = (i + chunk_size - 1 < total) and 1 or 0
    if i == 1 then
      table.insert(messages, string.format(
        "\x1b_Ga=T,f=100,t=d,i=%d,c=%d,r=%d,C=1,m=%d;%s\x1b\\",
        id, cols, rows, more, chunk
      ))
    else
      table.insert(messages, string.format("\x1b_Gm=%d;%s\x1b\\", more, chunk))
    end
  end
  return messages
end

vim.api.nvim_create_user_command("ImageTest", function()
  local img_display_rows = 12
  local img_display_cols = 20

  local chunks = build_kitty_chunks(png_path, IMAGE_ID, img_display_cols, img_display_rows)
  if not chunks then
    vim.notify("Cannot open: " .. png_path, vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local placeholder = {}
  for _ = 1, img_display_rows do
    table.insert(placeholder, "")
  end
  local lines = vim.list_extend({ "  Image in Floating Window", "" }, placeholder)
  table.insert(lines, "")
  table.insert(lines, "  Text below the image.")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local win_width = 44
  local win_height = #lines + 1
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = 2,
    col = math.floor((vim.o.columns - win_width) / 2),
    width = win_width,
    height = win_height,
    style = "minimal",
    border = "rounded",
    title = " Kitty Image Test ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_cursor(win, { 3, 0 })
  vim.cmd("redraw!")

  -- Write each APC message individually with try_write.
  -- Each message is complete (\x1b_G...\x1b\\), so even if TUI data
  -- appears between messages, the terminal parses each one correctly.
  for _, chunk in ipairs(chunks) do
    sync_write(chunk)
  end

  -- Clean up
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      sync_write(string.format("\x1b_Ga=d,d=i,i=%d\x1b\\", IMAGE_ID))
    end,
  })

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf })
  end
end, {})

vim.notify("Run :ImageTest to show image in floating window", vim.log.levels.INFO)
