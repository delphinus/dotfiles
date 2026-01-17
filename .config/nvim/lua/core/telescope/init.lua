---@param opts table?
---@param more_opts table?
---@return table
local function dropdown(opts, more_opts)
  local theme = require("telescope.themes").get_dropdown()
  return vim.tbl_deep_extend("force", theme, opts or {}, more_opts or {})
end

---@param name string
---@return fun(opts: table?): function
local function builtin(name)
  return function(opts)
    return function(more_opts)
      require("telescope.builtin")[name](dropdown(opts, more_opts))
    end
  end
end

---@param name string
---@param prop string?
---@return fun(opts: table?): function
local function extensions(name, prop)
  return function(opts)
    return function(more_opts)
      require("telescope").extensions[name][prop or name](dropdown(opts, more_opts))
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
