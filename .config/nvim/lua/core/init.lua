if vim.env.LOGFILE or vim.env.WARMUP then
  local start = vim.uv.hrtime()
  vim.api.nvim_create_autocmd("User", {
    once = true,
    -- snacks.nvim の場合はここを
    -- "SnacksDashboardOpened" とします。
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

local fn, uv = require("core.utils").globals()

vim.env.PATH = vim.env.PATH or "/usr/local/bin:/usr/bin:/bin"

-- Load here because lazy.nvim will reset 'runtimepath'
pcall(require, "core.local")

local Plugins = require "core.plugins"
local plugins = Plugins.new()
plugins:check_cores()
plugins:load()

require "core.options"

vim.g.loaded_getscriptPlugin = true
vim.g.loaded_logiPat = true
vim.g.loaded_rrhelper = true
vim.g.loaded_vimballPlugin = true
if fn.has "gui_running" ~= 1 then
  vim.g.plugin_scrnmode_disable = true
end

require("core.utils").export_globals()
