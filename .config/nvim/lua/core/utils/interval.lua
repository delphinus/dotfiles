local fn, uv, api = require("core.utils").globals()

---@class core.utils.interval.Interval
---@field name string
---@field term_seconds string
---@field _filename string?
local Interval = {}

---@param name string
---@param term_seconds integer
---@return core.utils.interval.Interval
Interval.new = function(name, term_seconds)
  return setmetatable({ name = name, term_seconds = term_seconds }, { __index = Interval })
end

---@return string
function Interval:filename()
  if not self._filename then
    self._filename = fn.stdpath "cache" .. "/" .. self.name
  end
  return self._filename
end

---@return boolean
function Interval:is_over()
  do
    local dir = vim.fs.dirname(self:filename())
    local st = uv.fs_stat(dir)
    if not st then
      assert(uv.fs_mkdir(dir, 448))
    end
  end
  local last = 0
  do
    local fd = uv.fs_open(self:filename(), "r", 438)
    if fd then
      local st = uv.fs_stat(fd)
      local data = uv.fs_read(fd, st.size, 0)
      assert(uv.fs_close(fd))
      last = tonumber(data) or 0
    end
  end

  return os.time() - last > self.term_seconds
end

---@return nil
function Interval:update()
  local fd = uv.fs_open(self:filename(), "w", 438)
  if fd then
    uv.fs_write(fd, os.time(), -1)
    assert(uv.fs_close(fd))
  else
    vim.notify("cannot open the file to write: " .. self:filename(), vim.log.levels.ERROR)
  end
end

return Interval
