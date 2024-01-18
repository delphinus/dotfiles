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
  api = api_tbl,

  -- NOTE: this is from lsp.lua
  is_empty_or_default = function(bufnr, option)
    if vim.bo[bufnr][option] == "" then
      return true
    end

    local info = vim.api.nvim_get_option_info2(option, { buf = bufnr })
    local scriptinfo = vim.tbl_filter(function(e)
      return e.sid == info.last_set_sid
    end, vim.fn.getscriptinfo())
    vim.print { scriptinfo = #scriptinfo }

    if #scriptinfo ~= 1 then
      return false
    end

    return vim.startswith(scriptinfo[1].name, vim.fn.expand "$VIMRUNTIME")
  end,

  ---@param plugin_name string
  load_denops_plugin = function(plugin_name)
    local dir = require("lazy.core.config").plugins[plugin_name].dir
    local name = plugin_name:gsub([[%.vim$]], ""):gsub([[^vim-]], "")
    vim.fn["denops#plugin#load"](name, dir .. "/denops/" .. name .. "/main.ts")
  end,
}
