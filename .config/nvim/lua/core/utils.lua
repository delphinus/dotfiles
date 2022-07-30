local api_tbl = setmetatable({ _cache = {} }, {
  __index = function(self, name)
    if not self._cache[name] then
      local func = vim.api["nvim_" .. name]
      if func then
        self._cache[name] = func
      else
        error("Unknown api func: " .. name, 2)
      end
    end
    return self._cache[name]
  end,
})

local function globals()
  return vim.fn, vim.loop, api_tbl
end

return {
  globals = globals,
  export_globals = function()
    local fn, uv, api = globals()
    _G.fn = fn
    _G.uv = uv
    _G.api = api
  end,
}
