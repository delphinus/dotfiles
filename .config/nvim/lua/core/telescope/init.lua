---@param name string
---@return fun(opts: table?): function
local function builtin(name)
  return function(opts)
    return function()
      require("telescope.builtin")[name](opts or {})
    end
  end
end

---@param name string
---@param prop string?
---@return fun(opts: table?): function
local function extensions(name, prop)
  local loaded = {}
  return function(opts)
    return function()
      local telescope = require "telescope"
      if not loaded[name] then
        telescope.load_extension(name)
        loaded[name] = true
      end
      telescope.extensions[name][prop or name](opts or {})
    end
  end
end

---@praam opts table?
---@return function
local function frecency(opts)
  return function()
    opts.path_display = require("core.telescope.frecency").path_display
    extensions "frecency"(opts)()
  end
end

return {
  builtin = builtin,
  extensions = extensions,
  frecency = frecency,
}
