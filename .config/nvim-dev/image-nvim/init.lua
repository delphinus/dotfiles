-- Minimal config for image.nvim testing
-- Usage: NVIM_APPNAME=nvim-dev/image-nvim nvim test.md
--
-- Requires: ImageMagick (brew install imagemagick)
--           luarocks --local --lua-version=5.1 install magick

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
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = true,
          only_render_image_at_cursor = false,
        },
      },
      max_width = 40,
      max_height = 12,
      max_width_window_percentage = 30,
      max_height_window_percentage = 30,
    },
  },
}, {
  change_detection = { enabled = false },
})

vim.cmd.colorscheme("tokyonight")
