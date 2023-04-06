---@class core.utils.palette.Colors
---@field name string
---@field from fun(name: string): core.utils.palette.Colors
---@field [core.utils.palette.Names] string
local Colors = {}

---@param name string
---@return core.utils.palette.Colors
function Colors.from(name)
  local colors = vim.F.npcall(require, "core.utils.palette." .. name) or {}
  colors.name = name
  return setmetatable(colors, { __index = Colors })
end

return Colors
