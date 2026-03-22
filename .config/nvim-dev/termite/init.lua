vim.o.laststatus = 2
vim.o.showtabline = 2

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

require("lazy").setup {
  {
    "ruicsh/termite.nvim",
    commit = "60184a1eaec3bf3f8f404eed4ee69b30f38cfe54",
    opts = {
      position = "bottom",
      shell = "/opt/homebrew/bin/fish",
      wo = {
        signcolumn = "yes:1",
        winblend = 30,
      },
    },
  },
}
