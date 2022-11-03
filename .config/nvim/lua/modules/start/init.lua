local config = require "modules.start.config"

return {
  -- basic {{{
  {
    "direnv/direnv.vim",
    config = function()
      vim.g.direnv_silent_load = 1
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    requires = {
      --{ "kyazdani42/nvim-web-devicons", opt = true },
      { "delphinus/nvim-web-devicons", branch = "feature/sfmono-square", opt = true },
      { "delphinus/eaw.nvim", module = { "eaw" } },
    },
    config = function()
      require("modules.start.config.lualine"):config()
    end,
  },

  {
    -- 'tpope/vim-unimpaired',
    "delphinus/vim-unimpaired",
    config = config.unimpaired,
  },

  { "vim-jp/vimdoc-ja" },
  -- }}}

  -- vim-script {{{
  { "vim-scripts/HiColors" },
  -- }}}

  -- lua-script {{{
  {
    "LumaKernel/nvim-visual-eof.lua",
    config = config.visual_eof,
  },

  {
    "delphinus/cellwidths.nvim",
    config = config.cellwidths.config,
    run = config.cellwidths.run,
  },
  -- }}}
}

-- vim:se fdm=marker:
