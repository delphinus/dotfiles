local Truncator = require "core.telescope.frecency.truncator"

---@class core.telescope.frecency.Opts
---@field __truncator core.telescope.frecency.truncator.Truncator?
---@field cwd string

---@param opts core.telescope.frecency.Opts
---@param path string
---@return string
local function path_display(opts, path)
  if not opts.__truncator then
    --TODO: use constant for prefix?
    opts.__truncator = Truncator.new { cwd = opts.cwd, gh_e_host = vim.g.gh_e_host or "", prefix = 8 }
  end
  return opts.__truncator:path_display(path)
end

return {
  path_display = path_display,
}
