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

---@alias core.utils.palette.Colors { [core.utils.palette.Names]: string }

---@alias core.utils.palette.Callback fun(colors: core.utils.palette.Colors): boolean?

---@class core.utils.palette.Palette
---@operator call(string):core.utils.palette.Colors
---@field autocmd fun(opts: core.utils.palette.AutocmdOpts): nil
---@field callback fun(cb: core.utils.palette.Callback): boolean?
---@field colors core.utils.palette.Colors

---@class core.utils.palette.AutocmdOpts
---@field name string
---@field callback core.utils.palette.Callback
---@field pattern string|string[]|nil

return setmetatable({}, {
  ---@param self core.utils.palette.Palette
  ---@param prop string
  __index = function(self, prop)
    if prop == "autocmd" then
      ---@param opts core.utils.palette.AutocmdOpts
      return function(opts)
        api.create_autocmd("ColorScheme", {
          group = api.create_augroup(opts.name .. "-palette", {}),
          pattern = opts.pattern,
          callback = self.callback(opts.callback),
        })
      end
    elseif prop == "callback" then
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
  end,
  __call = function(_, ...)
    local args = { ... }
    local name = args[1] or ""
    return vim.F.npcall(require, "core.utils.palette." .. name) or {}
  end,
}) --[[@as core.utils.palette.Palette]]
