local wezterm = require "wezterm"
local Timemachine = require "timemachine"

local battery_glyphs = {
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
}

local function isNaN(value)
  return value ~= value
end

local function battery(config)
  local info = wezterm.battery_info()[1]
  if isNaN(info.state_of_charge) then
    return {}
  end
  local f = math.floor
  local amount = f(info.state_of_charge * 10)
  local icon = battery_glyphs[info.state == "Charging" and "charging" or "normal"][amount + 1]
  local elapsed = info.time_to_empty or info.time_to_full
  local time = elapsed and (" 残り %d:%02d"):format(f(elapsed / 3600), f(elapsed % 3600 / 60)) or ""
  return {
    { Foreground = { Color = config.colors.ansi[3] } },
    { Background = { Color = config.colors.tab_bar.background } },
    { Text = ("%s %.0f%%%s "):format(icon, info.state_of_charge * 100, time) },
  }
end

local function key_table(config, window)
  local name = window:active_key_table()
  if not name then
    return {}
  end
  local bg = {
    copy_mode = config.colors.ansi[4],
    resize_pane = config.colors.ansi[6],
    search_mode = config.colors.ansi[7],
  }
  return {
    { Foreground = { Color = config.colors.ansi[1] } },
    { Background = { Color = bg[name] } },
    { Text = (" %s %s "):format(wezterm.nerdfonts.md_table, name) },
    "ResetAttributes",
  }
end

return function(config)
  local timemachine = Timemachine.new()

  wezterm.on("update-status", function(window, pane)
    local elements = {
      { Foreground = { Color = config.colors.ansi[4] } },
      { Background = { Color = config.colors.tab_bar.background } },
      {
        Text = ("%s %d:%d:%d "):format(
          wezterm.nerdfonts.md_window_maximize,
          window:window_id(),
          window:active_tab():tab_id(),
          pane:pane_id()
        ),
      },
      { Foreground = { Color = config.colors.ansi[5] } },
      { Text = wezterm.nerdfonts.md_clock_outline .. wezterm.strftime " %b %e %T " },
      "ResetAttributes",
    }
    local tm = timemachine:text()
    if tm then
      for i, value in ipairs {
        { Foreground = { Color = config.colors.ansi[2] } },
        { Background = { Color = config.colors.tab_bar.background } },
        { Text = tm },
      } do
        table.insert(elements, i, value)
      end
    end
    for i, value in ipairs(battery(config)) do
      table.insert(elements, i, value)
    end
    for _, value in ipairs(key_table(config, window)) do
      table.insert(elements, value)
    end
    window:set_right_status(wezterm.format(elements))
  end)
end
