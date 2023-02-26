---@param color_table { string: string }
---@return table
return function(color_table)
  local parse = require "ccc.utils.parse"
  local names = {}
  local converted = {}
  for name, rgb in pairs(color_table) do
    local r, g, b = rgb:match "(%x%x)(%x%x)(%x%x)"
    if r then
      table.insert(names, name)
      converted[name] = { parse.hex(r), parse.hex(g), parse.hex(b) }
    end
  end
  table.sort(names, function(a, b)
    return #a > #b
  end)
  local min = #names[#names]
  local re = vim.regex([[\<]] .. table.concat(names, [[\|]]) .. [[\>]])
  return {
    parse_color = function(_, s, init)
      init = vim.F.if_nil(init, 1)
      local target = s:sub(init)
      if #target < min then
        return
      end
      local start, end_ = re:match_str(target)
      if start then
        local name = target:sub(start + 1, end_)
        --vim.notify(vim.inspect({ start, end_, name }, { newline = "", indent = "" }))
        return start + init, end_ + init - 1, converted[name]
      end
    end,
  }
end
