local wezterm = require "wezterm"

---@class wezterm.TimemachineLatest
---@field hour integer
---@field minute integer

---@private
---@class wezterm.TimemachineCache
---@field tmutil string
---@field private _cache? wezterm.TimemachineLatest
local Cache = {}

---@return wezterm.TimemachineCache
Cache.new = function()
  return setmetatable({ tmutil = "/usr/bin/tmutil" }, { __index = Cache })
end

---@return wezterm.TimemachineLatest
function Cache:get()
  if not self._cache then
    self._cache = self:fetch()
  end
  return self._cache
end

function Cache:clear()
  self._cache = nil
end

---@private
---@return wezterm.TimemachineLatest?
function Cache:fetch()
  local success, stdout, stderr = wezterm.run_child_process { self.tmutil, "latestbackup" }
  if not success then
    return
  end
  local hour, minute = stdout:match "(%d%d)(%d%d)%d%d%.backup"
  return hour and minute and { hour = tonumber(hour), minute = tonumber(minute) }
end

---@class wezterm.TimemachineInfo
---@field backupPhase string
---@field progress? wezterm.TimemachineInfoProgress
---@field running 0|1

---@class wezterm.TimemachineInfoProgress
---@field bytesFormatted string
---@field percent number
---@field timeRemaining? number

---@class wezterm.Timemachine
---@field cache wezterm.TimemachineCache
---@field tmstatus string
---@field tmutil string
---@field enabled boolean
local Timemachine = {}

---@return wezterm.Timemachine
Timemachine.new = function()
  local self = setmetatable(
    { cache = Cache.new(), tmstatus = wezterm.home_dir .. "/git/dotfiles/bin/tmstatus", tmutil = "/usr/bin/tmutil" },
    { __index = Timemachine }
  )
  self.enabled = self:is_enabled()
  return self
end

---@return string?
function Timemachine:text()
  if not self.enabled then
    return
  end
  local success, stdout, stderr = wezterm.run_child_process { self.tmstatus }
  if not success then
    return stderr
  end
  local info = wezterm.json_parse(stdout)
  if info.running == 0 then
    return self:latest_backup()
  end
  self.cache:clear()
  return self:create_text(info)
end

---@private
---@return string
function Timemachine:latest_backup()
  local latest = self.cache:get()
  return latest and ("%s 最新 %d:%02d"):format(wezterm.nerdfonts.oct_stop, latest.hour, latest.minute) or ""
end

---@private
---@param info wezterm.TimemachineInfo
---@return string
function Timemachine:create_text(info)
  local progress = info.progress
  if not progress then
    return ("%s %s"):format(wezterm.nerdfonts.oct_stopwatch, info.backupPhase)
  end
  local remaining = progress.timeRemaining
  local f = math.floor
  local elapsed = remaining and (" 残り %d:%02d"):format(f(remaining / 3600), f(remaining % 3600 / 60)) or ""
  return ("%s %s ▐%s▌ %.1f%% %s%s"):format(
    wezterm.nerdfonts.oct_stopwatch,
    info.backupPhase,
    self:create_bar(progress.percent),
    progress.percent * 100,
    progress.bytesFormatted,
    elapsed
  )
end

---@private
---@param percent number
---@return string
function Timemachine:create_bar(percent)
  local glyphs = { "▏", "▎", "▍", "▌", "▋", "▊", "▉", "█" }
  local size = 12
  local f = math.floor
  local count = f(size * #glyphs * percent)
  local full = f(count / #glyphs)
  local result = {}
  for _ = 1, full do
    table.insert(result, glyphs[#glyphs])
  end
  local rest = count % #glyphs
  local spaces = size - full
  if rest > 0 then
    table.insert(result, glyphs[rest])
    spaces = spaces - 1
  end
  if spaces > 0 then
    for _ = 1, spaces do
      table.insert(result, " ")
    end
  end
  return table.concat(result)
end

---@private
---@return boolean
function Timemachine:is_enabled()
  local success, stdout = wezterm.run_child_process { self.tmutil, "destinationinfo" }
  return success and not stdout:match "No destinations configured"
end

return Timemachine
