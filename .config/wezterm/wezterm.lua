local wezterm = require "wezterm"
local colors = require "colors"
local const = require "const"
local keys = require "keys"
local key_tables = require "key_tables"

local config = wezterm.config_builder()

config.adjust_window_size_when_changing_font_size = false
config.default_prog = { const.tmux_run_bin }
config.disable_default_key_bindings = true
config.enable_kitty_keyboard = true
config.font = wezterm.font "SF Mono Square"
config.font_size = 16.0
config.front_end = "WebGpu"
config.hyperlink_rules =
  { { regex = const.url_regex, format = "$0" }, { regex = [=[[-.\w]+@[-.\w]+]=], format = "mailto:$0" } }
config.initial_cols = 200
config.initial_rows = 80
config.macos_window_background_blur = 20
config.quick_select_patterns = { const.url_regex, const.hash_regex, const.path_regex }
config.set_environment_variables = { SHELL = const.fish_bin }
-- config.use_fancy_tab_bar = false
config.warn_about_missing_glyphs = false
config.webgpu_power_preference = "HighPerformance"
config.window_background_opacity = 0.90
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"

colors(config)
keys(config)
key_tables(config)

return config
