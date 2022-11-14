local config = require "modules.lsp.config"

local function ts(plugin)
  plugin.event = { "BufNewFile", "BufRead" }
  plugin.wants = { "nvim-treesitter" }
  return plugin
end

return {
  { -- {{{ nvim-lspconfig
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    module = { "lsp_lines" },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre" },
    requires = {
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        event = { "FocusLost", "CursorHold" },
        config = config.mason_tool_installer,
      },
      { "folke/neodev.nvim", module = { "neodev" } },
      { "williamboman/mason-lspconfig.nvim", module = { "mason-lspconfig" } },
      { "williamboman/mason.nvim", module = { "mason" } },
    },
    wants = {
      "neodev.nvim",
      "mason.nvim",
      "mason-lspconfig.nvim",
      -- needs these plugins to setup capabilities
      "cmp-nvim-lsp",
    },
    config = config.lspconfig,
  }, -- }}}

  ts { "RRethy/nvim-treesitter-endwise" },

  ts {
    "m-demare/hlargs.nvim",
    config = function()
      require("hlargs").setup { color = "#d08770" }
    end,
  },

  ts {
    "mfussenegger/nvim-treehopper",
    modules = { "tsht" },
    setup = config.treehopper.setup,
  },

  ts { "nvim-treesitter/nvim-treesitter-refactor" },
  ts { "nvim-treesitter/nvim-treesitter-textobjects" },
  ts { "nvim-treesitter/playground" },
  ts { "romgrk/nvim-treesitter-context" },
  ts { "p00f/nvim-ts-rainbow", config = config.ts_rainbow },

  { -- {{{ nvim-treesitter
    "nvim-treesitter/nvim-treesitter",
    event = { "BufRead", "BufNewFile", "InsertEnter" },
    config = config.treesitter,
    run = ":TSUpdate",
  }, -- }}}

  {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "FocusLost", "CursorHold" },
    config = config.null_ls.config,
    run = config.null_ls.run,
  },
}

-- vim:se fdm=marker:
