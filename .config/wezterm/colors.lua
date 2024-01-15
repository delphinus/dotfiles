local wezterm = require "wezterm"

return function(config)
  config.color_scheme = "nord"
  config.colors = {
    tab_bar = {
      active_tab = { bg_color = "#88c0d0", fg_color = "#2e3440" },
      inactive_tab = { bg_color = "#434c5e", fg_color = "#d8dee9" },
      inactive_tab_hover = { bg_color = "#4C566A", fg_color = "#d8dee9" },
      new_tab = { bg_color = "#4c566a", fg_color = "#d8dee9" },
      new_tab_hover = { bg_color = "#4c566a", fg_color = "#d8dee9" },
    },
  }
  config.window_frame = {
    font = wezterm.font { family = "SF Mono Square", weight = "Bold" },
    font_size = 16.0,
    active_titlebar_bg = "#2e3440",
    inactive_titlebar_bg = "#2e3440",
  }
end
