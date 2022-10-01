local config = require "modules.telescope.config"
local function o(plugin)
  plugin.opt = true
  return plugin
end

return {
  o { "delphinus/telescope-memo.nvim" },
  --o { "kyazdani42/nvim-web-devicons" },
  o { "delphinus/nvim-web-devicons", branch = "feature/sfmono-square" },
  o { "nvim-lua/popup.nvim" },
  o { "nvim-telescope/telescope-file-browser.nvim" },
  o {
    "nvim-telescope/telescope-frecency.nvim",
    module = { "telescope._extensions.frecency.db_client" },
    requires = o { "kkharji/sqlite.lua" },
    wants = { "sqlite.lua" },
  },
  o { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
  o { "nvim-telescope/telescope-ghq.nvim" },
  o { "nvim-telescope/telescope-github.nvim" },
  o { "nvim-telescope/telescope-node-modules.nvim" },
  o { "nvim-telescope/telescope-smart-history.nvim", requires = o { "tami5/sql.nvim" }, wants = { "sql.nvim" } },
  o { "nvim-telescope/telescope-symbols.nvim" },
  o { "nvim-telescope/telescope-z.nvim" },
  o { "stevearc/dressing.nvim" },

  {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    -- set modules in detail because telescope-frecency is needed before
    -- telescope itself to save its history in opening buffers.
    module_pattern = {
      "^telescope$",
      "^telescope%.builtin$",
      "^telescope%.actions%.",
      "^telescope%.from_entry$",
      "^telescope%.previewers%.",
    },
    requires = {
      { "plenary.nvim" },
    },
    wants = {
      "dressing.nvim",
      "nvim-web-devicons",
      "popup.nvim",
      "telescope-file-browser.nvim",
      "telescope-frecency.nvim",
      "telescope-fzf-native.nvim",
      "telescope-ghq.nvim",
      "telescope-github.nvim",
      "telescope-memo.nvim",
      "telescope-node-modules.nvim",
      "telescope-smart-history.nvim",
      "telescope-symbols.nvim",
      "telescope-z.nvim",
    },
    setup = config.telescope.setup,
    config = config.telescope.config,
  },
}
