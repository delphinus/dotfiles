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
end
