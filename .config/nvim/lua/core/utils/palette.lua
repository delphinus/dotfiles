---@alias core.utils.palette.Names
---| "black"
---| "red"
---| "green"
---| "yellow"
---| "blue"
---| "magenta"
---| "cyan"
---| "white"
---| "bright_black"
---| "bright_red"
---| "bright_green"
---| "bright_yellow"
---| "bright_blue"
---| "bright_magenta"
---| "bright_cyan"
---| "bright_white"
---| "orange"
---| "comment"
---| "dark_white"
---| "dark_black"
---| "border"

---@alias core.utils.palette.Colors { [core.utils.palette.Names]: string }

---@class core.utils.palette.Palette
---@operator call(string):core.utils.palette.Colors
---@field callback fun(cb: fun(colors: core.utils.palette.Colors): boolean?): boolean?
---@field colors core.utils.palette.Colors

return setmetatable({}, {
  ---@param self core.utils.palette.Palette
  ---@param prop string
  ---@return function
  __index = function(self, prop)
    if prop == "callback" then
      ---@param cb fun(colors: core.utils.palette.Colors): boolean?
      ---@return fun(args: { match: string }): boolean?
      return function(cb)
        return function(args)
          return cb(self(args.match))
        end
      end
    elseif prop == "colors" then
      return self(vim.g.colors_name)
    end
    return function() end
  end,
  __call = function(_, ...)
    local args = { ... }
    local name = args[1] or ""
    return vim.F.npcall(require, "core.utils.palette." .. name) or {}
  end,
}) --[[@as core.utils.palette.Palette]]
