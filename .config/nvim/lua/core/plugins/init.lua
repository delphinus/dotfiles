local _, uv, _ = require("core.utils").globals()

local Package = require "core.plugins.package"
local fn = require("core.utils").globals()

---@class core.plugins.Plugins
---@field root string
---@field core_dir string
---@field packages table[]
local Plugins = {}

---@return boolean
local function exists(path)
  local st = uv.fs_stat(path)
  return not not st
end

---@return core.plugins.Plugins
Plugins.new = function()
  local root = fn.stdpath "data" .. "/site/pack"
  return setmetatable({
    root = root,
    core_dir = root .. "/core/start",
    packages = {
      { "nvim-lua/plenary.nvim", branch = "master" },
      { "delphinus/f_meta.nvim" },
      { "delphinus/lazy_require.nvim" },
    },
  }, { __index = Plugins })
end

---@return nil
function Plugins:check_cores()
  for _, definition in ipairs(self.packages) do
    local package = Package.new(self.core_dir, definition[1], { branch = definition.branch })
    if not exists(package.dir) then
      package:clone()
    end
  end
end

---@return nil
function Plugins:load()
  require "core.lazy"
end

return Plugins
