local fn, uv, api = require("core.utils").globals()

vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10

vim.keymap.set("n", "<C-j>", "<C-w>w")
vim.keymap.set("n", "<C-k>", "<C-w>W")
vim.keymap.set("n", "<C-c>", "<Cmd>q<CR>")

vim.keymap.set({ "n", "v" }, "<C-d>", "3<C-d>")
vim.keymap.set({ "n", "v" }, "<C-u>", "3<C-u>")
vim.keymap.set("n", "_", "<C-w>_")

vim.keymap.set("n", "ZA", "<Cmd>qa<CR>")

-- https://twitter.com/uvrub/status/1341036672364945408
vim.keymap.set("i", "<CR>", "<C-g>u<CR>", { silent = true })

vim.keymap.set("n", "ZE", "<Cmd>restart<CR>")
vim.keymap.set("n", "ZR", "<Cmd>restart lua require('persistence').load { last = true }<CR>")

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

-- https://blog.pulkitgangwar.com/neovim-configuration-from-scratch-to-lsp
-- Move the selected region up or down
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<M-P>", function()
  vim.system {
    "wezterm",
    "cli",
    "split-pane",
    "--right",
    "--",
    "mcat",
    "-pt",
    "kanagawa",
    vim.fn.expand "%:p",
  }
end)

-- Open macOS Dictionary for the word under cursor or selected text
local function lookup_dictionary()
  local buf = vim.api.nvim_get_current_buf()

  ---@pram c vim.lsp.Client
  local can_hover = vim.iter(vim.lsp.get_clients { bufnr = buf }):any(function(c)
    return c:supports_method "textDocument/hover"
  end)
  if can_hover then
    vim.lsp.buf.hover()
    return
  end

  local word
  local mode = api.get_mode().mode

  if mode == "v" or mode == "V" or mode == "\22" then
    -- Visual mode: get selected text
    vim.cmd 'normal! "vy'
    word = vim.fn.getreg "v"
  else
    -- Normal mode: get word under cursor
    word = vim.fn.expand "<cword>"
  end

  if word ~= "" then
    vim.system { "open", "dict://" .. word }
  end
end

-- Set K mapping only if not already mapped
api.create_autocmd({ "FileType", "BufWinEnter" }, {
  desc = "Set K to look up word in macOS Dictionary if not already mapped",
  group = api.create_augroup("macos_dictionary_mapping", {}),
  callback = function()
    local buf = api.get_current_buf()
    -- Check if K is already mapped in normal or visual mode
    if fn.mapcheck("K", "n") == "" then
      vim.keymap.set("n", "K", lookup_dictionary, { buffer = buf, desc = "Look up word in macOS Dictionary" })
    end
    if fn.mapcheck("K", "v") == "" then
      vim.keymap.set("v", "K", lookup_dictionary, { buffer = buf, desc = "Look up word in macOS Dictionary" })
    end
  end,
})
