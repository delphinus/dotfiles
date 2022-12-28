local fn, uv = require("core.utils").globals()

local lazy_path = fn.stdpath "data" .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazy_path) then
  fn.system { "git", "clone", "--filter=blob:none", "--single-branch", "https://github.com/folke/lazy.nvim", lazy_path }
end
vim.opt.runtimepath:prepend(lazy_path)

local plugins = {}
for _, name in ipairs { "start", "opt", "cmp", "lsp", "telescope" } do
  table.insert(plugins, require("lazies." .. name))
end

require("lazy").setup(plugins, {
  defaults = { lazy = true },
  ui = {
    icons = {
      loaded = "●",
      not_loaded = "○",
      cmd = "",
      config = "",
      event = "",
      ft = "",
      init = "",
      keys = "",
      plugin = "",
      runtime = "",
      source = "",
      start = "",
      task = "✔",
      lazy = "",
      list = {
        "●",
        "→",
        "∗",
        "‒",
      },
    },
  },
})
