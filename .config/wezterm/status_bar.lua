local wezterm = require "wezterm"

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
    if name then
      table.insert(elements, { Foreground = { Color = config.colors.ansi[1] } })
      table.insert(elements, { Background = { Color = bg[name] } })
      table.insert(elements, { Text = (" %s %s "):format(wezterm.nerdfonts.md_table, name) })
      table.insert(elements, "ResetAttributes")
    end
    window:set_right_status(wezterm.format(elements))
  end)
end
