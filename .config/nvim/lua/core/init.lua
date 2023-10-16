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
