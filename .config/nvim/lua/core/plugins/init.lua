local _, uv, api = require("core.utils").globals()

local Package = require "core.plugins.package"
local fn = require("core.utils").globals()

---@class core.plugins.Plugins
---@field root string
---@field packer_dir string
---@field evacuated_packer_dir string
---@field core_dir string
---@field packages table[]
---@field use_lazy boolean
local Plugins = {}

---@return boolean
local function exists(path)
  local st = uv.fs_stat(path)
  return not not st
end

---@param use_lazy boolean
---@return core.plugins.Plugins
Plugins.new = function(use_lazy)
  local root = fn.stdpath "data" .. "/site/pack"
  return setmetatable({
    root = root,
    packer_dir = root .. "/packer",
    evacuated_packer_dir = "/tmp/packer",
    core_dir = root .. "/core/start",
    use_lazy = use_lazy,
    packages = {
      { "nvim-lua/plenary.nvim", branch = "master" },
      { "delphinus/f_meta.nvim" },
      { "delphinus/lazy_require.nvim" },
    },
  }, { __index = Plugins })
end

---@return nil
function Plugins:check_managers()
  if self.use_lazy then
    if exists(self.packer_dir) then
      vim.notify("Packer dir exists and we use lazy.nvim instead. Evacuating packer dir...", vim.log.levels.WARN)
      uv.fs_rename(self.packer_dir, self.evacuated_packer_dir)
    end
  else
    if exists(self.evacuated_packer_dir) then
      vim.notify("Evacuated packer dir exists and we use packer.nvim. Moving packer dir...", vim.log.levels.WARN)
      uv.fs_rename(self.evacuated_packer_dir, self.packer_dir)
    end
  end
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
  if self.use_lazy then
    require "core.lazy"
  else
    if vim.env.NVIM_PROFILE then
      require("plenary.profile").start("/tmp/profile.log", { flame = true })
      api.create_autocmd("VimEnter", {
        callback = function()
          require("plenary.profile").stop()
        end,
      })
    end

    local pack = require "core.pack"
    pack:load_script()
  end
end

return Plugins
