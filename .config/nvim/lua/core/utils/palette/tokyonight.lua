return setmetatable({ t = os.time(), _colors = {} }, {
  __index = function(self, key)
    local _colors = rawget(self, "_colors")
    return rawget(_colors, key)
  end,
  __call = function(self, colors)
    local _colors = rawget(self, "_colors")
    for k, v in pairs(colors) do
      rawset(_colors, k, v)
    end
    vim.print(self)
  end,
})
