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
    --"nvim-telescope/telescope-frecency.nvim",
    "delphinus/telescope-frecency.nvim",
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
  o {
    "gbprod/yanky.nvim",
    keys = {
      { "n", "<Plug>(YankyCycleBackward)" },
      { "n", "<Plug>(YankyCycleForward)" },
      { "n", "<Plug>(YankyGPutAfter)" },
      { "n", "<Plug>(YankyGPutBefore)" },
      { "n", "<Plug>(YankyPutAfter)" },
      { "n", "<Plug>(YankyPutBefore)" },
      { "x", "<Plug>(YankyGPutAfter)" },
      { "x", "<Plug>(YankyGPutBefore)" },
      { "x", "<Plug>(YankyPutAfter)" },
      { "x", "<Plug>(YankyPutBefore)" },
    },
    requires = o { "kkharji/sqlite.lua", opt = true },
    setup = config.yanky.setup,
    config = config.yanky.config,
    wants = { "sqlite.lua" },
  },

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
    wants = {
      "dressing.nvim",
      "nvim-notify",
      "nvim-web-devicons",
      "plenary.nvim",
      "popup.nvim",
      "project.nvim",
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
      "yanky.nvim",
    },
    setup = config.telescope.setup,
    config = config.telescope.config,
  },
}
