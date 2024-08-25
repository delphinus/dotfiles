(function()
  local start = vim.uv.hrtime()
  vim.api.nvim_create_autocmd("User", {
    pattern = "DashboardLoaded",
    callback = function()
      local ok, stats = pcall(require, "lazy.stats")
      if ok then
        stats.track "DashboardLoaded"
        print(("it takes %.3f seconds until DashboardLoaded"):format(stats.stats().times.DashboardLoaded))
      end
      vim.api.nvim__redraw { flush = true }
    end,
  })
end)()

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
