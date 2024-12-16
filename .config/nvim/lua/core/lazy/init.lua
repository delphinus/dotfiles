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

do
  local stats = require "lazy.stats"
  stats.cputime() -- HACK: this is needed to use clock_gettime()
  stats.monotonic = function()
    local ffi = require "ffi"
    local pnano = assert(ffi.new("nanotime[?]", 1))
    local CLOCK_MONOTONIC = jit.os == "OSX" and 6 or 1
    ffi.C.clock_gettime(CLOCK_MONOTONIC, pnano)
    return tonumber(pnano[0].tv_sec) * 1e3 + tonumber(pnano[0].tv_nsec) / 1e6
  end

  if vim.env.LOGFILE then
    local start = stats.monotonic()
    vim.api.nvim_create_autocmd("User", {
      once = true,
      pattern = "DashboardLoaded",
      callback = function()
        local finish = stats.monotonic()
        vim.fn.writefile({ tostring(finish - start) }, vim.env.LOGFILE, "a")
        vim.schedule(function()
          vim.cmd.qall { bang = true }
        end)
      end,
    })
  end
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
