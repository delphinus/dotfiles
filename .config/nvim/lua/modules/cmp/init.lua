local config = require "modules.cmp.config"

local function i(p)
  p.event = { "InsertEnter" }
  return p
end

local function c(p)
  p.event = { "CmdlineEnter" }
  return p
end

return {
  {
    "vim-skk/skkeleton",
    keys = {
      { "i", "<Plug>(skkeleton-enable)" },
      { "i", "<Plug>(skkeleton-disable)" },
      { "c", "<Plug>(skkeleton-enable)" },
      { "c", "<Plug>(skkeleton-disable)" },
      { "l", "<Plug>(skkeleton-enable)" },
      { "l", "<Plug>(skkeleton-disable)" },
    },
    wants = {
      "denops.vim",
    },
    setup = config.skkeleton.setup,
    config = config.skkeleton.config,

    requires = {
      i {
        "delphinus/skkeleton_indicator.nvim",
        setup = config.skkeleton_indicator.setup,
        config = function()
          require("skkeleton_indicator").setup()
        end,
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    module = { "cmp" },
    setup = config.cmp.setup,
    config = config.cmp.config,

    requires = {
      { "hrsh7th/cmp-nvim-lua", ft = "lua" },
      { "mtoohey31/cmp-fish", ft = "fish" },
      { "onsails/lspkind-nvim", module = { "lspkind" } },

      c { "hrsh7th/cmp-cmdline" },
      c { "hrsh7th/cmp-path" },

      i { "andersevenrud/cmp-tmux" },
      i { "delphinus/cmp-ctags" },
      i { "dmitmel/cmp-digraphs" },
      i { "hrsh7th/cmp-buffer" },
      i { "hrsh7th/cmp-emoji" },
      i { "hrsh7th/cmp-nvim-lsp" },
      i { "lukas-reineke/cmp-rg" },
      i { "octaltree/cmp-look" },
      i { "ray-x/cmp-treesitter" },
      i { "rinx/cmp-skkeleton" },

      i {
        "dcampos/cmp-snippy",
        requires = {
          { "dcampos/nvim-snippy", module = { "snippy" } },
          { "honza/vim-snippets", opt = true },
        },
        wants = { "vim-snippets" },
        config = function()
          require("snippy").setup {}
        end,
      },
    },
  },
}
