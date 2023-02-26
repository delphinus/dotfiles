---@param color_table { string: string }
---@return table
return function(color_table)
  local parse = require "ccc.utils.parse"
  local converted = {}
  for name, rgb in pairs(color_table) do
    local r, g, b = rgb:match "(%x%x)(%x%x)(%x%x)"
    if r then
      converted[name] = { parse.hex(r), parse.hex(g), parse.hex(b) }
    end
  end
  return {
    ---@param _ any
    ---@param s string
    ---@param init integer
    parse_color = function(_, s, init)
      for name, parsed in pairs(converted) do
        local start, end_ = s:find(name, init)
        if start then
          return start, end_, parsed
        end
      end
    end,
  }
end
