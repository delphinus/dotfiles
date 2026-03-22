-- Bare Neovim config for Markdown comparison
-- Usage: NVIM_APPNAME=nvim-dev/bare nvim README.md

vim.opt.number = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "no"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "folke/tokyonight.nvim", opts = {} },
})

vim.cmd.colorscheme("tokyonight")
