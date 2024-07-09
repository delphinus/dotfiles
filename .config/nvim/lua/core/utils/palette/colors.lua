---@class core.utils.palette.Colors
---@field name string
---@field is_dark boolean
---@field from fun(name: string): core.utils.palette.Colors
---@field [core.utils.palette.Names] string
---@field [string] string
local Colors = {}

---@param name string
---@return core.utils.palette.Colors
function Colors.from(name)
  local colors = vim.F.npcall(require, "core.utils.palette." .. name) or {}
  colors.name = name
  return setmetatable(colors, { __index = Colors })
end

---@param name string
---@return string[]
function Colors.list(name)
  local colors = vim.F.npcall(require, "core.utils.palette." .. name) or {}
  return {
    colors.black,
    colors.red,
    colors.green,
    colors.yellow,
    colors.blue,
    colors.magenta,
    colors.cyan,
    colors.white,
    colors.white,
    colors.nord12, -- orange
  }
end

return Colors
