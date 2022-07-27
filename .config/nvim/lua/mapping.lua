vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10

vim.keymap.set({ "n", "v" }, "<C-d>", "3<C-d>")
vim.keymap.set({ "n", "v" }, "<C-u>", "3<C-u>")
vim.keymap.set("n", "_", "<C-w>_")

-- https://twitter.com/uvrub/status/1341036672364945408
vim.keymap.set("i", "<CR>", "<C-g>u<CR>", { silent = true })

local function toggle_quickfix()
  local cmd
  local loclist = fn.getloclist(0, { size = 0, winid = 0 })
  if loclist.size > 0 then
    cmd = loclist.winid == 0 and "lopen" or "lclose"
  else
    local is_opened
    for _, win in ipairs(api.list_wins()) do
      local buf = api.win_get_buf(win)
      if api.buf_get_option(buf, "filetype") == "qf" then
        is_opened = true
      end
    end
    cmd = is_opened and "cclose" or "copen"
  end
  vim.cmd("silent " .. cmd)
end

vim.keymap.set("n", "qq", toggle_quickfix)

api.create_autocmd("FileType", {
  group = api.create_augroup("toggle_quickfix_with_enter", {}),
  pattern = "qf",
  callback = function()
    api.create_autocmd("BufWinLeave", { once = true, callback = toggle_quickfix })
  end,
})

-- quit with `q` when started by `view`
api.create_autocmd("VimEnter", {
  group = api.create_augroup("set_mapping_for_view", {}),
  command = [[if &readonly | nnoremap q <Cmd>qa<CR> | endif]],
})

-- When editing a file, always jump to the last known cursor position. Don't
-- do it when the position is invalid or when inside an event handler
-- (happens when dropping a file on gvim).
api.create_autocmd("BufReadPost", {
  group = api.create_augroup("jump_to_the_last_position", {}),
  callback = function()
    if vim.bo.buftype ~= "terminal" then
      local last_pos = fn.line [['"]]
      if last_pos >= 1 and last_pos <= fn.line "$" then
        vim.cmd.execute [['normal! g`"']]
      end
    end
  end,
})

-- The native implementation of vim-higlihghtedyank in NeoVim
api.create_autocmd("TextYankPost", {
  group = api.create_augroup("highlighted_yank", {}),
  callback = function()
    vim.highlight.on_yank { higroup = "StatusLine" }
  end,
})
