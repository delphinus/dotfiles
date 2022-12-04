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

  { "lewis6991/impatient.nvim" },
  -- }}}
}

-- vim:se fdm=marker:
