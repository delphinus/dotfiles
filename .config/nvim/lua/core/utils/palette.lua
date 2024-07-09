local api = require("core.utils").api

local colors = require "core.utils.palette.colors"

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
---@alias core.utils.palette.Opts table<core.utils.palette.Callback>|table<string, core.utils.palette.Callback>
---@alias core.utils.palette.Autocmd fun(opts: core.utils.palette.Opts): nil

---@class core.utils.palette.Palette
---@field autocmd table<string, core.utils.palette.Callback>
---@field colors core.utils.palette.Colors
---@operator call(string): core.utils.palette.Autocmd

---@param self core.utils.palette.Palette
---@param prop string
local function __index(self, prop)
  if prop == "colors" then
    return colors.from(vim.g.colors_name)
  elseif prop == "list" then
    return colors.list(vim.g.colors_name)
  end
end

---@param self core.utils.palette.Palette
---@param name string
---@return core.utils.palette.Autocmd)
local function __call(self, name)
  return function(opts)
    vim.validate {
      opts = {
        opts,
        function(v)
          if type(v) ~= "table" then
            return false
          elseif #v > 1 then
            return false
          end
          for _, f in pairs(opts) do
            if type(f) ~= "function" then
              return false
            end
          end
          return true
        end,
        "callback table",
      },
    }
    api.create_autocmd("ColorScheme", {
      desc = ("Set the palette for ColorScheme: %s"):format(name),
      group = api.create_augroup(name .. "-palette", {}),
      ---@param args { match: string }
      callback = function(args)
        local scheme = args.match
        local p = colors.from(scheme)
        p.is_dark = vim.o.background == "dark"
        if opts[scheme] then
          opts[scheme](p)
        end
        if opts[1] then
          opts[1](p)
        end
      end,
    })
  end
end

return setmetatable({ autocmd = {} }, { __index = __index, __call = __call }) --[[@as core.utils.palette.Palette]]
