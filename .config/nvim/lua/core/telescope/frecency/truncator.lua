---@alias PlenaryPath core.telescope.frecency.truncator.PlenaryPath
---@alias PlenaryPathPath core.telescope.frecency.truncator.PlenaryPathPath

---@class core.telescope.frecency.truncator.PlenaryPathPath
---@field sep string

---@class core.telescope.frecency.truncator.PlenaryPath
---@field path PlenaryPathPath
---@field filename string
---@field make_relative fun(self: PlenaryPath, cwd: string): nil
---@field is_absolute fun(self: PlenaryPath): boolean
---@field shorten fun(self: PlenaryPath, len: integer, exclude: integer[]): string

local _, uv, api = require("core.utils").globals()

---@class core.telescope.frecency.truncator.Opts
---@field cwd string
---@field gh_e_host string
---@field prefix integer

---@class core.telescope.frecency.truncator.Re
---@field vimruntime string
---@field home string
---@field gh_dir string
---@field gh_e_dir string
---@field ghq_dir string
---@field packer_dir string

---@class core.telescope.frecency.truncator.Truncator
---@field cwd string
---@field gh_e_host string
---@field width integer
---@field re core.telescope.frecency.truncator.Re
local Truncator = {}

---@param opts core.telescope.frecency.truncator.Opts
---@return core.telescope.frecency.truncator.Truncator
Truncator.new = function(opts)
  local state = require "telescope.state"
  local status = state.get_status(api.get_current_buf())
  local length = api.win_get_width(status.results_win) - status.picker.selection_caret:len()
  local home = uv.os_homedir()
  ---@param str string
  ---@return string
  local function re(str)
    local r = str:gsub("([]%[%%*+?-])", "%%%1")
    return r
  end

  return setmetatable({
    cwd = opts.cwd,
    width = length - opts.prefix,
    re = {
      vimruntime = re(vim.env.VIMRUNTIME),
      home = re(home),
      gh_dir = re(home .. "/git/github.com"),
      gh_e_dir = re(home .. "/git/" .. opts.gh_e_host),
      ghq_dir = re(home .. "/git"),
      packer_dir = re(home .. "/.local/share/nvim/site/pack/packer"),
    },
  }, { __index = Truncator })
end

---@param path string
---@return string
function Truncator:path_display(path)
  local Path = require "plenary.path"
  local p = Path:new(path)
  self:replace_known_dirs(p)
  self:truncate(p)
  return p.filename
end

function Truncator:replace_known_dirs(path)
  path:make_relative(self.cwd)
  path.filename = path.filename
    :gsub(self.re.vimruntime, "")
    :gsub(self.re.gh_dir, "")
    :gsub(self.re.ghq_dir, "")
    :gsub(self.re.packer_dir, "")
    :gsub(self.re.home, "~")
end

function Truncator:truncate(path)
  local sep = path.path.sep
  local _, count = (path.filename .. sep):gsub(sep, sep)
  if path:is_absolute() then
    count = count - 1
  end
  ---@type integer[]
  local exclude = { count }
  for j = 1, count - 1 do
    table.insert(exclude, j)
  end
  while true do
    local shortened = path:shorten(1, exclude)
    if #exclude == 1 or #shortened <= self.width then
      path.filename = shortened
      return
    end
    table.remove(exclude)
  end
end

return Truncator
