local serialize = require "core.utils.serialize"

local function byte_code_require(module)
  local f = assert(loadstring(([[return require "%s"]]):format(module)))
  return string.dump(f)
end

local function index(self, method)
  return function(opts)
    local f_str = ([[
      local module = assert(loadstring(%s))()
      local opts = assert(loadstring(%s))()
      module.%s(opts)
    ]]):format(vim.inspect(self.load_module), vim.inspect(serialize(opts)), method)
    return assert(loadstring(f_str))
  end
end

return function(module)
  return setmetatable({
    load_module = byte_code_require(module),
  }, {
    __index = index,
  })
end
