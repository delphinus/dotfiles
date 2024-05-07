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
  return function(opts)
    return function(more_opts)
      local o = vim.tbl_extend("force", opts or {}, more_opts or {})
      require("telescope").extensions[name][prop or name](o)
    end
  end
end

---@praam opts table?
---@return fun(more_opts: table?): nil
local function frecency(opts)
  return function(more_opts)
    local o = vim.tbl_extend("force", opts or {}, more_opts or {})
    -- NOTE: use the former one
    -- extensions "frecency"(o) { path_display = require("core.telescope.frecency").path_display }
    -- NOTE: use filename_first
    extensions "frecency"(o) {}
  end
end

---@param opts table?
---@return fun(more_opts: table?): nil
local function help_tags(opts)
  return function(more_opts)
    require "core.lazy.all"()
    builtin "help_tags"(opts)(more_opts)
  end
end

return {
  builtin = builtin,
  extensions = extensions,
  frecency = frecency,
  help_tags = help_tags,
}
