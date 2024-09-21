local wezterm = require "wezterm"
local colors = require "colors"
local const = require "const"
local keys = require "keys"
local key_tables = require "key_tables"
local op_envs = require "op_envs"

local config = wezterm.config_builder()

config.adjust_window_size_when_changing_font_size = false
config.default_prog = { "/opt/homebrew/bin/fish" }
config.disable_default_key_bindings = true
config.enable_csi_u_key_encoding = true
config.enable_kitty_keyboard = true
config.font = wezterm.font "SF Mono Square"
config.font_size = 16.0
config.front_end = "WebGpu"
config.hyperlink_rules =
  { { regex = const.url_regex, format = "$0" }, { regex = [=[[-.\w]+@[-.\w]+]=], format = "mailto:$0" } }
config.initial_cols = 200
config.initial_rows = 80
config.macos_window_background_blur = 20
config.native_macos_fullscreen_mode = true
config.quick_select_patterns = { const.url_regex, const.hash_regex, const.path_regex }
-- config.use_fancy_tab_bar = false
config.warn_about_missing_glyphs = false
config.window_background_opacity = 0.96
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"

config.unix_domains = { { name = "unix" } }
config.default_gui_startup_args = { "connect", "unix" }
config.set_environment_variables = op_envs { SHELL = const.fish }

colors(config)
keys(config)
key_tables(config)

wezterm.on("user-var-changed", function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}
  if name == "ZEN_MODE" then
    local incremental = value:find "+"
    local number_value = tonumber(value)
    if incremental ~= nil then
      while number_value > 0 do
        window:perform_action(wezterm.action.IncreaseFontSize, pane)
        number_value = number_value - 1
      end
      overrides.enable_tab_bar = false
    elseif number_value < 0 then
      window:perform_action(wezterm.action.ResetFontSize, pane)
      overrides.font_size = nil
      overrides.enable_tab_bar = true
    else
      overrides.font_size = number_value
      overrides.enable_tab_bar = false
    end
  end
  window:set_config_overrides(overrides)
end)

wezterm.on("update-right-status", function(window, pane)
  local name = window:active_key_table()
  local bg = {
    copy_mode = "#ebcb8b",
    resize_pane = "#b48ead",
  }
  if name then
    window:set_right_status(wezterm.format {
      { Foreground = { Color = "#2e3440" } },
      { Background = { Color = bg[name] } },
      { Text = " TABLE: " .. name .. " " },
      "ResetAttributes",
    })
  else
    window:set_right_status ""
  end
end)

return config
