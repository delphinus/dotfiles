-- Minimal config for md-render.nvim screenshot
-- Usage: NVIM_APPNAME=nvim-dev/md-render nvim

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "folke/tokyonight.nvim", opts = {} },
  {
    dir = vim.fn.expand("~/.local/share/nvim/lazy/md-render.nvim"),
    cmd = "MdRenderDemo",
  },
}, {
  install = { missing = false },
  change_detection = { enabled = false },
})

vim.cmd.colorscheme("tokyonight")
