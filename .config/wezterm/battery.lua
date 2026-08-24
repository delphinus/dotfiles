---@type Wezterm
local wezterm = require "wezterm"

---@class wezterm.Battery
---@field enabled boolean
local Battery = {}

Battery.new = function()
  local function is_nan(value)
    return value ~= value
  end
  return setmetatable({ enabled = not is_nan(wezterm.battery_info()[1].state_of_charge) }, { __index = Battery })
end

-- 残量に応じた深刻度。充電中は減らないので常に ok。
---@param info wezterm.BatteryInfo
---@return "ok"|"warn"|"critical"
local function severity(info)
  if info.state == "Charging" or info.state == "Full" then
    return "ok"
  elseif info.state_of_charge < 0.15 then
    return "critical"
  elseif info.state_of_charge < 0.3 then
    return "warn"
  end
  return "ok"
end

---@return string?
---@return ("ok"|"warn"|"critical")?
function Battery:text()
  if not self.enabled then
    return
  end
  local info = wezterm.battery_info()[1]
  local f = math.floor
  local glyphs = {
    normal = {
      wezterm.nerdfonts.md_battery_outline,
      wezterm.nerdfonts.md_battery_10,
      wezterm.nerdfonts.md_battery_20,
      wezterm.nerdfonts.md_battery_30,
      wezterm.nerdfonts.md_battery_40,
      wezterm.nerdfonts.md_battery_50,
      wezterm.nerdfonts.md_battery_60,
      wezterm.nerdfonts.md_battery_70,
      wezterm.nerdfonts.md_battery_80,
      wezterm.nerdfonts.md_battery_90,
      wezterm.nerdfonts.md_battery_check,
    },
    charging = {
      wezterm.nerdfonts.md_battery_charging_outline,
      wezterm.nerdfonts.md_battery_charging_10,
      wezterm.nerdfonts.md_battery_charging_20,
      wezterm.nerdfonts.md_battery_charging_30,
      wezterm.nerdfonts.md_battery_charging_40,
      wezterm.nerdfonts.md_battery_charging_50,
      wezterm.nerdfonts.md_battery_charging_60,
      wezterm.nerdfonts.md_battery_charging_70,
      wezterm.nerdfonts.md_battery_charging_80,
      wezterm.nerdfonts.md_battery_charging_90,
      wezterm.nerdfonts.md_battery_check,
    },
    suspended = {
      wezterm.nerdfonts.md_battery_clock,
    },
  }
  local amount = f(info.state_of_charge * 10)
  local icon = info.state == "Unknown" and glyphs.suspended[1]
    or glyphs[info.state == "Charging" and "charging" or "normal"][amount + 1]
  local elapsed = info.time_to_empty or info.time_to_full
  local time = elapsed and (" 残り %d:%02d"):format(f(elapsed / 3600), f(elapsed % 3600 / 60)) or ""
  return ("%s %.0f%%%s"):format(icon, info.state_of_charge * 100, time), severity(info)
end

return Battery
