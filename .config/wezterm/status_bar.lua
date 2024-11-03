local wezterm = require "wezterm"
local Battery = require "battery"
local Timemachine = require "timemachine"

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

local function domain(config)
  local type, path = wezterm.mux.get_domain():label():match "(.*) mux (.*)"
  return type == "SSH"
      and {
        { Foreground = { Color = config.colors.ansi[1] } },
        { Background = { Color = config.colors.ansi[3] } },
        { Text = (" %s %s "):format(wezterm.nerdfonts.md_console_network, path) },
      }
    or {}
end

return function(config)
  local battery = Battery.new()
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
    local meta = pane:get_metadata() or {}
    if meta.is_tardy then
      local sec = meta.since_last_response_ms / 1000
      for i, value in ipairs {
        { Foreground = { Color = config.colors.ansi[7] } },
        { Text = ("%s %.2f"):format(wezterm.nerdfonts "md_airplane_clock", sec) },
      } do
        table.insert(elements, 3 + i, value)
      end
    end
    local tm = timemachine:text()
    if tm then
      for i, value in ipairs {
        { Foreground = { Color = config.colors.ansi[2] } },
        { Background = { Color = config.colors.tab_bar.background } },
        { Text = tm .. " " },
      } do
        table.insert(elements, i, value)
      end
    end
    local bt = battery:text()
    if bt then
      for i, value in ipairs {
        { Foreground = { Color = config.colors.ansi[3] } },
        { Background = { Color = config.colors.tab_bar.background } },
        { Text = bt .. " " },
      } do
        table.insert(elements, i, value)
      end
    end
    for _, value in ipairs(key_table(config, window)) do
      table.insert(elements, value)
    end
    for _, value in ipairs(domain(config)) do
      table.insert(elements, value)
    end
    table.insert(elements, { Background = { Color = config.colors.tab_bar.background } })
    table.insert(elements, 1, { Text = " " })
    window:set_right_status(wezterm.format(elements))
  end)
end
