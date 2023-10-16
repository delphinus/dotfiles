_G.pp = function(v)
  vim.notify(vim.inspect(v, { newline = "", indent = "" }))
end

local fn, uv = require("core.utils").globals()

local pack_path = fn.stdpath "data" .. "/lazy/"
local lazy_path = pack_path .. "lazy.nvim"
if not uv.fs_stat(lazy_path) then
  fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazy_path,
  }
end
vim.opt.runtimepath:prepend(lazy_path)

local definitions = vim.env.MINIMAL and { "minimal", "cmp" } or { "minimal", "start", "opt", "cmp", "lsp", "telescope" }
local plugins = {}
for _, name in ipairs(definitions) do
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
  concurrency = vim.env.LIGHT and 10 or 50,
  checker = { enabled = not vim.env.LIGHT },
  dev = { path = "~/git/github.com/delphinus" },
  ui = {
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
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
      lazy = "󰒲",
      list = {
        "●",
        "→",
        "∗",
        "‒",
      },
    },
  },
})
