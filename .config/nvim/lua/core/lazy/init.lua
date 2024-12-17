if vim.env.LOGFILE or vim.env.WARMUP then
  local start = vim.uv.hrtime()
  vim.api.nvim_create_autocmd("User", {
    once = true,
    pattern = "DashboardLoaded",
    callback = function()
      if vim.env.LOGFILE then
        local finish = vim.uv.hrtime()
        vim.fn.writefile({ tostring((finish - start) / 1e6) }, vim.env.LOGFILE, "a")
      end
      vim.schedule_wrap(vim.cmd.qall) { bang = true }
    end,
  })
end

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
    local vimdoc = Path:new(config.options.root, "vimdoc-ja")
    vim
      .system({ "git", "reset", "--hard" }, { cwd = tostring(vimdoc) }, function(info)
        if info.code == 0 then
          vim.schedule(function()
            vim.notify("vimdoc-ja resetted hardly", vim.log.levels.DEBUG)
          end)
        else
          vim.schedule(function()
            vim.notify("git reset --hard failed", vim.log.levels.ERROR)
          end)
        end
      end)
      :wait()
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
