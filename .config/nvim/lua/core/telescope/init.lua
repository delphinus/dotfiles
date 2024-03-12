---@param name string
---@return fun(opts: table?): function
local function builtin(name)
  return function(opts)
    return function(more_opts)
      local o = vim.tbl_extend("force", opts or {}, more_opts or {})
      require("telescope.builtin")[name](o)
    end
  end
end

---@param name string
---@param prop string?
---@return fun(opts: table?): function
local function extensions(name, prop)
  local loaded = {}
  return function(opts)
    return function(more_opts)
      local telescope = require "telescope"
      if not loaded[name] then
        telescope.load_extension(name)
        loaded[name] = true
      end
      local o = vim.tbl_extend("force", opts or {}, more_opts or {})
      telescope.extensions[name][prop or name](o)
    end
  end
end

---@praam opts table?
---@return function
local function frecency(opts)
  return function(more_opts)
    local o = vim.tbl_extend("force", opts or {}, more_opts or {})
    extensions "frecency"(o) { path_display = require("core.telescope.frecency").path_display }
  end
end

return {
  builtin = builtin,
  extensions = extensions,
  frecency = frecency,
}
