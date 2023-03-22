local api = require("core.utils").api

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

---@alias core.utils.palette.Callback fun(colors: core.utils.palette.Colors): boolean?
---@alias core.utils.palette.Opts { [string]: core.utils.palette.Callback }

---@class core.utils.palette.Colors
---@field name string
---@field [core.utils.palette.Names] string
---@operator call(string):core.utils.palette.Colors

---@class core.utils.palette.Palette
---@field autocmd fun(opts: core.utils.palette.Opts): nil
---@field callback fun(cb: core.utils.palette.Callback): boolean?
---@field colors core.utils.palette.Colors
---@operator call(string):core.utils.palette.Colors

return setmetatable({}, {
  ---@param self core.utils.palette.Palette
  ---@param prop string
  __index = function(self, prop)
    if prop == "callback" then
      ---@param cb fun(colors: core.utils.palette.Colors): boolean?
      ---@return fun(args: { match: string }): boolean?
      return function(cb)
        return function(args)
          return cb(self.colors(args.match))
        end
      end
    elseif prop == "colors" then
      local function get_colors(_, name)
        local colors = vim.F.npcall(require, "core.utils.palette." .. name) or {}
        colors.name = name
        return colors
      end
      return setmetatable(get_colors(_, vim.g.colors_name), { __call = get_colors })
    end
  end,
  ---@param self core.utils.palette.Palette
  ---@param opts core.utils.palette.Opts
  __call = function(self, opts)
    local name = vim.tbl_keys(opts)[1]
    if name then
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup(name .. "-palette", {}),
        callback = self.callback(opts[name]),
      })
    end
  end,
}) --[[@as core.utils.palette.Palette]]
