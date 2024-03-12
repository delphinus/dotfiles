---@param name string
---@return fun(opts: table?): function
local function builtin(name)
  return function(opts)
    return require("telescope.builtin")[name](opts or {})
  end
end

---@param name string
---@param prop string?
---@return fun(opts: table?): function
local function extensions(name, prop)
  local loaded = {}
  return function(opts)
    local telescope = require "telescope"
    if not loaded[name] then
      telescope.load_extension(name)
      loaded[name] = true
    end
    return telescope.extensions[name][prop or name](opts or {})
  end
end

---@praam opts table?
---@return function
local function frecency(opts)
  opts.path_display = require("core.telescope.frecency").path_display
  return extensions "frecency"(opts)
end

return {
  builtin = builtin,
  extensions = extensions,
  frecency = frecency,
}
