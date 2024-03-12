local fn, uv, api = require("core.utils").globals()

vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10

vim.keymap.set({ "n", "v" }, "<C-d>", "3<C-d>")
vim.keymap.set({ "n", "v" }, "<C-u>", "3<C-u>")
vim.keymap.set("n", "_", "<C-w>_")

-- https://twitter.com/uvrub/status/1341036672364945408
vim.keymap.set("i", "<CR>", "<C-g>u<CR>", { silent = true })

local function silent(cmd)
  vim.cmd("silent " .. cmd)
end

local function when_not_qf(f)
  return function()
    if vim.opt.buftype == "quickfix" then
      vim.notify "already in quickfix window"
    else
      f()
    end
  end
end

vim.keymap.set("n", "qq", function()
  local qflist = fn.getqflist { size = 0, winid = 0 }
  silent "lclose"
  if qflist.size > 0 then
    silent(qflist.winid == 0 and "copen" or "cclose")
  else
    silent "cclose"
  end
end, { desc = "Open/Close quickfix window" })

vim.keymap.set(
  "n",
  "QQ",
  when_not_qf(function()
    local loclist = fn.getloclist(0, { size = 0, winid = 0 })
    silent "cclose"
    if loclist.size > 0 then
      silent(loclist.winid == 0 and "lopen" or "lclose")
    else
      silent "lclose"
    end
  end),
  { desc = "Open/Close location-list window" }
)

vim.keymap.set("n", "qc", function()
  vim.notify "clear quickfix list"
  fn.setqflist {}
end, { desc = "Clear quickfix window" })

vim.keymap.set(
  "n",
  "QC",
  when_not_qf(function()
    vim.notify "clear location list"
    fn.setloclist(0, {})
  end),
  { desc = "Clear location-list window" }
)

api.create_autocmd("VimEnter", {
  desc = "Quit with `q` when started by `view`",
  group = api.create_augroup("set_mapping_for_view", {}),
  command = [[if &readonly | nnoremap q <Cmd>qa<CR> | endif]],
})

api.create_autocmd("TextYankPost", {
  desc = "The native implementation of vim-higlihghtedyank in NeoVim",
  group = api.create_augroup("highlighted_yank", {}),
  callback = function()
    vim.highlight.on_yank { higroup = "StatusLine" }
  end,
})

-- https://blog.pulkitgangwar.com/neovim-configuration-from-scratch-to-lsp
-- Move the selected region up or down
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
