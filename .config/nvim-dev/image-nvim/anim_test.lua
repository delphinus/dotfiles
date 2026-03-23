-- Test animated GIF via frame extraction + timer cycling
-- Usage: NVIM_APPNAME=nvim-dev/image-nvim nvim
--        :luafile ~/.config/nvim-dev/image-nvim/anim_test.lua
--        :AnimTest

local uv = vim.uv or vim.loop

local tty_path = nil
do
  local handle = io.popen("tty 2>/dev/null")
  if handle then
    tty_path = vim.fn.trim(handle:read("*a"))
    handle:close()
    if tty_path == "" or tty_path == "not a tty" then tty_path = nil end
  end
end

local function term_write(data)
  if data == "" then return end
  if tty_path then
    local f = io.open(tty_path, "w")
    if f then f:write(data); f:close(); return end
  end
end

local function move_cursor(x, y)
  term_write("\x1b[" .. y .. ";" .. x .. "H")
  uv.sleep(1)
end

local gif_path = vim.fn.expand("~/.config/nvim-dev/image-nvim/animated.gif")
local IMAGE_ID_BASE = 60

vim.api.nvim_create_user_command("AnimTest", function()
  -- Extract frames with magick
  local tmp_dir = vim.fn.tempname() .. "_frames"
  vim.fn.mkdir(tmp_dir, "p")
  local result = vim.system({
    "magick", gif_path, "-coalesce", tmp_dir .. "/frame_%03d.png"
  }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("Failed to extract frames: " .. (result.stderr or ""), vim.log.levels.ERROR)
    return
  end

  -- Collect frame files
  local frames = {}
  for _, f in ipairs(vim.fn.glob(tmp_dir .. "/frame_*.png", false, true)) do
    table.insert(frames, f)
  end
  table.sort(frames)
  if #frames == 0 then
    vim.notify("No frames extracted", vim.log.levels.ERROR)
    return
  end
  vim.notify(string.format("Extracted %d frames", #frames))

  -- Open floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = { "  Animated GIF (" .. #frames .. " frames)", "" }
  for _ = 1, 10 do table.insert(lines, "") end
  table.insert(lines, "  q to close")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", row = 2,
    col = math.floor((vim.o.columns - 30) / 2),
    width = 30, height = #lines + 1,
    style = "minimal", border = "rounded",
    title = " Anim Test ", title_pos = "center",
  })
  vim.api.nvim_win_set_cursor(win, { 3, 0 })
  vim.cmd("redraw!")

  local win_pos = vim.api.nvim_win_get_position(win)
  local screen_row = win_pos[1] + 4
  local screen_col = win_pos[2] + 3

  -- Transmit all frames
  local frame_ids = {}
  for i, frame_path in ipairs(frames) do
    local id = IMAGE_ID_BASE + i
    local b64_path = vim.base64.encode(frame_path)
    term_write(string.format(
      "\x1b_Ga=t,f=100,t=t,i=%d,q=2;%s\x1b\\",
      id, b64_path
    ))
    table.insert(frame_ids, id)
  end

  -- Cycle frames with timer
  local current_frame = 1
  local timer = uv.new_timer()
  timer:start(0, 200, vim.schedule_wrap(function()
    if not vim.api.nvim_win_is_valid(win) then
      timer:stop(); timer:close()
      return
    end

    term_write("\x1b[s")
    move_cursor(screen_col, screen_row)
    term_write(string.format(
      "\x1b_Ga=p,i=%d,c=10,r=8,C=1,q=2\x1b\\",
      frame_ids[current_frame]
    ))
    term_write("\x1b[u")

    current_frame = current_frame % #frames + 1
  end))

  vim.keymap.set("n", "q", function()
    timer:stop(); timer:close()
    for _, id in ipairs(frame_ids) do
      term_write(string.format("\x1b_Ga=d,d=i,i=%d\x1b\\", id))
    end
    vim.fn.delete(tmp_dir, "rf")
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf })
end, {})

vim.notify("Run :AnimTest", vim.log.levels.INFO)
