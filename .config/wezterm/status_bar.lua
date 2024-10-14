local wezterm = require "wezterm"

local has_battery = not not wezterm.battery_info()[1]

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

local function battery(config)
  local f = math.floor
  local info = wezterm.battery_info()[1]
  local amount = f(info.state_of_charge * 10)
  local icon = battery_glyphs[info.status == "Charging" and "charging" or "normal"][amount + 1]
  local elapsed = info.time_to_empty or info.time_to_full
  local time = elapsed and (" 残り %d:%02d"):format(f(elapsed / 3600), f(elapsed % 3600 / 60)) or ""
  return {
    { Foreground = { Color = config.colors.ansi[3] } },
    { Background = { Color = config.colors.tab_bar.background } },
    { Text = ("%s %.1f%%%s "):format(icon, info.state_of_charge * 100, time) },
  }
end

return function(config)
  wezterm.on("update-status", function(window, pane)
    local name = window:active_key_table()
    local bg = {
      copy_mode = config.colors.ansi[4],
      resize_pane = config.colors.ansi[6],
    }
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
    if has_battery then
      for i, value in ipairs(battery(config)) do
        table.insert(elements, i, value)
      end
    end
    if name then
      table.insert(elements, { Foreground = { Color = config.colors.ansi[1] } })
      table.insert(elements, { Background = { Color = bg[name] } })
      table.insert(elements, { Text = (" %s %s "):format(wezterm.nerdfonts.md_table, name) })
      table.insert(elements, "ResetAttributes")
    end
    window:set_right_status(wezterm.format(elements))
  end)
end
