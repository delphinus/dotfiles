---@class core.lazy.all.All
---@operator call:nil
---@field loaded boolean

return setmetatable({ loaded = false }, {
  ---@param self core.lazy.all.All
  __call = function(self)
    if self.loaded then
      return
    end
    local lazy = require "lazy"
    ---@param p LazyPlugin
    local to_load = vim.tbl_filter(function(p)
      return not not (p.lazy and not p._.loaded and not p._.dep and not p._.cond)
    end, lazy.plugins())
    ---@param p LazyPlugin
    lazy.load { plugins = vim.tbl_map(function(p)
      return p.name
    end, to_load) }
    self.loaded = true
  end,
}) --[[@as core.lazy.all.All]]
