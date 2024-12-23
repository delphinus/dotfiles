if vim.env.PROF then
  local snacks = vim.fn.stdpath "data" .. "/lazy/snacks.nvim"
  vim.opt.runtimepath:append(snacks)
  require("snacks.profiler").startup {
    startup = { "VeryLazy" },
  }
end

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

local use_minimal = not not vim.env.MINIMAL or vim.env.USER == "root"
local definitions = use_minimal and { "minimal", "cmp" } or { "minimal", "start", "opt", "cmp", "lsp", "telescope" }
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
  ignore_ftdetect[lazypath .. "/" .. i] = true
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyUpdatePre",
  group = vim.api.nvim_create_augroup("lazy-update-pre", {}),
  callback = function()
    local Path = require "plenary.path"
    local config = require "lazy.core.config"
    local to_reset = { "vimdoc-ja", "moody.nvim" }
    local done = {}
    for _, plugin in ipairs(to_reset) do
      local path = Path:new(config.options.root, plugin).filename
      for _, case in ipairs {
        { type = "reset", cmd = { "git", "reset", "--hard" } },
        { type = "clean", cmd = { "git", "clean", "-df" } },
      } do
        vim.system(case.cmd, { cwd = path }, function(info)
          table.insert(done, { plugin = plugin, type = case.type, code = info.code })
        end)
      end
    end
    vim.wait(5000, function()
      return #done == #to_reset * 2
    end)
    -- HACK: load nvim-notify definitely instead of calling vim-notify
    local notify = require "notify"
    -- HACK: open notification windows above the one of lazynvim
    local opts = {
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 10000 })
      end,
    }
    for _, result in ipairs(done) do
      if result.code == 0 then
        notify(("done successfully to %s: %s"):format(result.type, result.plugin), vim.log.levels.INFO, opts)
      else
        notify(("failed to %s: %s"):format(result.type, result.plugin), vim.log.levels.ERROR, opts)
      end
    end
  end,
})

require("lazy.core.loader").did_ftdetect = ignore_ftdetect

require("lazy").setup(plugins, {
  defaults = { lazy = true },
  concurrency = vim.env.LIGHT and 10 or 50,
  checker = { enabled = not vim.env.LIGHT, notify = false },
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
