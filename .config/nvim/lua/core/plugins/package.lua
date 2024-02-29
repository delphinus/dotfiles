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
  local notify = vim.schedule_wrap(vim.notify)
  vim
    .system({ "git", "clone", self.url, self.dir, "-b", self.opts.branch }, {}, function(obj)
      if obj.code == 0 then
        notify("Cloned " .. self.name, vim.log.levels.INFO)
      else
        notify("Failed to clone " .. self.name, vim.log.levels.ERROR)
      end
    end)
    :wait()
end

return Package
