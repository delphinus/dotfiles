---@class core.plugins.package.Package
---@field dir string
---@field name string
---@field url string
---@field opts core.plugins.package.Opts
local Package = {}

---@class core.plugins.package.Opts
---@field branch string default: "main"

---@param base string
---@param name string
---@param opts core.plugins.package.Opts
Package.new = function(base, name, opts)
  local dir = base .. "/" .. vim.fs.basename(name)
  return setmetatable({
    dir = dir,
    name = name,
    url = "https://github.com/" .. name,
    opts = vim.tbl_extend("force", { branch = "main" }, opts or {}),
  }, { __index = Package })
end

---@return nil
function Package:clone()
  vim.cmd(("!git clone %s %s -b %s"):format(self.url, self.dir, self.opts.branch))
end

return Package
