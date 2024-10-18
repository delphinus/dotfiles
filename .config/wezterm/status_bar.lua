local wezterm = require "wezterm"

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

local bar_glyphs = {
  "▏",
  "▎",
  "▍",
  "▌",
  "▋",
  "▊",
  "▉",
  full = "█",
  left = "▐",
  right = "▌",
}
local bar_division = 8
local bar_size = 6

local function tmstatus(config)
  local result = {
    { Foreground = { Color = config.colors.ansi[2] } },
    { Background = { Color = config.colors.tab_bar.background } },
  }
  local success, stdout, stderr = wezterm.run_child_process { wezterm.home_dir .. "/git/dotfiles/bin/tmstatus" }
  if not success then
    table.insert(result, { Text = stderr })
    return result
  end
  local info = wezterm.json_parse(stdout)
  if info.running == 0 then
    table.insert(result, { Text = wezterm.nerdfonts.oct_stop .. " " })
    return result
  elseif not info.progress then
    table.insert(result, { Text = ("%s %s "):format(wezterm.nerdfonts.oct_stopwatch, info.backupPhase) })
    return result
  end
  local f = math.floor
  local count = f(bar_size * bar_division * info.progress.percent)
  local full_count = f(count / bar_division)
  local rest = count % bar_division
  local glyphs = ""
  for _ = 1, full_count do
    glyphs = glyphs .. bar_glyphs.full
  end
  if rest > 0 then
    glyphs = glyphs .. bar_glyphs[rest]
  end
  if full_count < bar_size - 1 then
    for _ = 1, bar_size - full_count - 1 do
      glyphs = glyphs .. " "
    end
  end
  table.insert(result, {
    Text = ("%s %s%s%s %.1f%% %s "):format(
      wezterm.nerfonts.oct_stopwatch,
      bar_glyphs.left,
      glyphs,
      bar_glyphs.right,
      info.progress.percent,
      info.backupPhase
    ),
  })
  return result
end

return function(config)
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
    for i, value in ipairs(tmstatus(config)) do
      table.insert(elements, i, value)
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
