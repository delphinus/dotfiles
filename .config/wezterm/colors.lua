---@type Wezterm
local wezterm = require "wezterm"

return function(config)
  local tokyonight = "/Users/jinnouchi.yasushi/.local/share/nvim/lazy/tokyonight.nvim"
  local sweetie = "/Users/jinnouchi.yasushi/.local/share/nvim/lazy/sweetie.nvim"
  if #wezterm.glob(tokyonight) > 0 then
    config.colors = wezterm.color.load_scheme(tokyonight .. "/extras/wezterm/tokyonight_storm.toml")
  elseif #wezterm.glob(sweetie) > 0 then
    config.colors = wezterm.color.load_scheme(sweetie .. "/extras/wezterm/sweetie_dark.toml")
  else
    config.color_scheme = "nord"
  end
  config.window_frame = {
    font = wezterm.font { family = "SF Mono Square", weight = "Bold" },
    font_size = 16.0,
  }
  -- tab_title.lua が各タブを角丸チップとして描くので、地の色を一段暗くして
  -- チップを浮かせる。tokyonight の inactive_tab_edge が bg_dark 相当。
  local tab_bar = config.colors and config.colors.tab_bar
  if tab_bar and tab_bar.inactive_tab_edge then
    tab_bar.background = tab_bar.inactive_tab_edge
  end
end
