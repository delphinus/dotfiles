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
  local success, stdout, _ = wezterm.run_child_process { self.tmutil, "latestbackup" }
  if not success then
    return
  end
  local hour, minute = stdout:match "(%d%d)(%d%d)%d%d%.backup"
  return hour and minute and { hour = tonumber(hour), minute = tonumber(minute) }
end

---@class wezterm.TimemachineInfo
---@field BackupPhase string
---@field DateOfStateChange string
---@field Progress? wezterm.TimemachineInfoProgress
---@field Running "0"|"1"

---@class wezterm.TimemachineInfoProgress
---@field Percent string
---@field TimeRemaining? string
---@field bytes string
---@field files string

---@class wezterm.Timemachine
---@field bash string
---@field cache wezterm.TimemachineCache
---@field date string
---@field plutil string
---@field tail string
---@field tmutil string
---@field enabled boolean
local Timemachine = {}

---@return wezterm.Timemachine
Timemachine.new = function()
  local self = setmetatable({
    bash = "/bin/bash",
    cache = Cache.new(),
    date = "/bin/date",
    plutil = "/usr/bin/plutil",
    tail = "/usr/bin/tail",
    tmutil = "/usr/bin/tmutil",
  }, { __index = Timemachine })
  self.enabled = self:is_enabled()
  return self
end

---@param n_str string
local function commify(n_str, need_unit)
  local n = tonumber(n_str) or 0
  local num, unit
  if n > 1e9 then
    num = n / 1e9
    unit = "GB"
  elseif n > 1e6 then
    num = n / 1e6
    unit = "MB"
  else
    num = n
    unit = "KB"
  end
  local int, dec = tostring(num):match "([^%.]+)%.?(%d*)"
  local commified = tostring(int):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
  local result = (#commified >= 3 or not dec) and commified
    or ("%s.%s"):format(commified, dec:sub(1, math.max(4 - #commified, 1)))
  return need_unit and ("%s %s"):format(result, unit) or result
end

---@return string?
function Timemachine:text()
  if not self.enabled then
    return
  end
  local success, stdout, stderr = wezterm.run_child_process {
    self.bash,
    "-c",
    ("%s status | %s -n +2 | %s -convert json -o - -- -"):format(self.tmutil, self.tail, self.plutil),
  }
  if not success then
    return stderr
  end
  local info = wezterm.json_parse(stdout)
  local is_running = (info.Running or (info.LastReport and info.LastReport.Running)) == "1"
  if not is_running then
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
  local refreshed = ""
  if info.DateOfStateChange then
    local success, stdout, stderr =
      wezterm.run_child_process { self.date, "-jf", "%F %T %z", "+ 最終更新 %H:%m ", info.DateOfStateChange }
    refreshed = success and stdout or stderr
  end
  local progress = info.Progress
  if not progress then
    return ("%s %s%s"):format(wezterm.nerdfonts.oct_stopwatch, info.BackupPhase, refreshed)
  end
  local remaining = tonumber(progress.TimeRemaining)
  local f = math.floor
  local elapsed = remaining and (" 残り %d:%02d"):format(f(remaining / 3600), f(remaining % 3600 / 60)) or ""
  local percent = tonumber(progress.Percent) or 0
  return ("%s %s ▐%s▌ %s %s files%s%s"):format(
    wezterm.nerdfonts.oct_stopwatch,
    info.BackupPhase,
    self:create_bar(percent),
    commify(progress.bytes, true),
    commify(progress.files),
    elapsed,
    refreshed
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
