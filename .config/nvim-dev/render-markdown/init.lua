-- render-markdown.nvim config for Markdown comparison
-- Usage: NVIM_APPNAME=nvim-dev/render-markdown nvim README.md

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
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}, {
  -- Ensure treesitter markdown parser is installed
})

vim.cmd.colorscheme("tokyonight")

-- Auto-install markdown treesitter parser
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  callback = function()
    local ok, ts_install = pcall(require, "nvim-treesitter.install")
    if ok then
      ts_install.ensure_installed({ "markdown", "markdown_inline" })
    end
  end,
})
