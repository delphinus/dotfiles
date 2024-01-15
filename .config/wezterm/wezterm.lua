local wezterm = require "wezterm"
local colors = require "colors"
local keys = require "keys"
local key_tables = require "key_tables"

local config = wezterm.config_builder()
local url_regex = [[https?://[^<>"\s{-}\^⟨⟩`│⏎]+]]
local hash_regex = [=[[a-f\d]{4,}|[A-Z_]{4,}]=]
local path_regex = [[~?(?:[-.\w]*/)+[-.\w]*]]

config.adjust_window_size_when_changing_font_size = false
config.default_prog = { "/Users/jinnouchi.yasushi/git/dotfiles/bin/tmux-run" }
config.disable_default_key_bindings = true
config.enable_kitty_keyboard = true
config.font = wezterm.font "SF Mono Square"
config.font_size = 16.0
config.front_end = "WebGpu"
config.hyperlink_rules =
  { { regex = url_regex, format = "$0" }, { regex = [=[[-.\w]+@[-.\w]+]=], format = "mailto:$0" } }
config.initial_cols = 200
config.initial_rows = 80
config.macos_window_background_blur = 20
config.quick_select_patterns = { url_regex, hash_regex, path_regex }
config.set_environment_variables = { SHELL = "/opt/homebrew/bin/fish" }
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
