local fn, uv = require("core.utils").globals()

local pack_path = fn.stdpath "data" .. "/lazy/"
local lazy_path = pack_path .. "lazy.nvim"
if not uv.fs_stat(lazy_path) then
  fn.system { "git", "clone", "--filter=blob:none", "--single-branch", "https://github.com/folke/lazy.nvim", lazy_path }
end
vim.opt.runtimepath:prepend(lazy_path)

local plugins = {}
for _, name in ipairs { "start", "opt", "cmp", "lsp", "telescope" } do
  table.insert(plugins, require("lazies." .. name))
end

local ignore_ftdetect = {}
for _, i in ipairs {
  "Vim-Jinja2-Syntax",
  "ansible-vim",
  "bats.vim",
  "ejs-syntax",
  "moonscript-vim",
  "plantuml-syntax",
  "skkdict.vim",
  "vader.vim",
  "vifm.vim",
  "vim-caddyfile",
  "vim-coffee-script",
  "vim-cpanfile",
  "vim-firestore",
  "vim-fish",
  "vim-mustache-handlebars",
  "vim-perl",
  "xslate-vim",
} do
  ignore_ftdetect[pack_path .. i] = true
end

require("lazy.core.loader").did_ftdetect = ignore_ftdetect

require("lazy").setup(plugins, {
  defaults = { lazy = true },
  concurrency = 20,
  checker = { enabled = true },
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
