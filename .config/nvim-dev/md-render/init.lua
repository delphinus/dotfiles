-- Minimal config for md-render.nvim screencast (telescope + snacks)
-- Usage: NVIM_APPNAME=nvim-dev/md-render nvim

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "folke/tokyonight.nvim", opts = {} },

  -- telescope.nvim
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope md_render find_files<cr>", desc = "Find files (md-render)" },
      { "<leader>fg", "<cmd>Telescope md_render live_grep<cr>", desc = "Live grep (md-render)" },
    },
    opts = {
      defaults = {
        layout_strategy = "vertical",
        layout_config = {
          preview_cutoff = 1,
          preview_height = 0.5,
        },
      },
    },
  },

  -- snacks.nvim
  {
    "folke/snacks.nvim",
    lazy = false,
    keys = {
      { "<leader>sf", function() Snacks.picker.files() end, desc = "Find files (snacks)" },
      { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep (snacks)" },
    },
    opts = function()
      local preview = require("md-render.snacks").preview()
      return {
        picker = {
          sources = {
            files = { preview = preview },
            grep = { preview = preview },
          },
        },
      }
    end,
  },

  -- nvim-treesitter (parsers for code block highlighting in md-render)
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install { "python", "lua", "bash", "ruby" }
    end,
  },

  -- md-render.nvim (local dev copy)
  {
    dir = vim.fn.expand "~/.local/share/nvim/lazy/md-render.nvim",
    dependencies = { "delphinus/budoux.lua" },
    cmd = { "MdRender", "MdRenderDemo", "MdRenderTab", "MdRenderPager" },
  },
}, {
  install = { missing = false },
  change_detection = { enabled = false },
})

vim.cmd.colorscheme "tokyonight"
