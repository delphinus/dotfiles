---@type Wezterm
local wezterm = require "wezterm"
local colors = require "colors"
local const = require "const"
local keys = require "keys"
local key_tables = require "key_tables"
local open_uri = require "open_uri"
local status_bar = require "status_bar"
local tab_title = require "tab_title"

local config = wezterm.config_builder()

config.adjust_window_size_when_changing_font_size = false
config.custom_block_glyphs = true
config.default_prog = { const.fish }
config.disable_default_key_bindings = true
config.enable_csi_u_key_encoding = true
config.enable_kitty_keyboard = true
config.font = wezterm.font "SF Mono Square"
config.font_size = 16.0
config.front_end = "WebGpu"
config.hyperlink_rules =
  { { regex = const.regex.url, format = "$0" }, { regex = const.regex.mail, format = "mailto:$0" } }
config.initial_cols = 200
config.initial_rows = 80
config.macos_window_background_blur = 20
config.native_macos_fullscreen_mode = true
config.quick_select_patterns = { const.regex.url, const.regex.tag, const.regex.path, const.regex.file }
-- タブ幅の上限。タブが少ないときはここまで広がる。多いときは tab_title.lua が
-- ステータスの幅を差し引いてここより狭く絞る ([[tab_bar_metrics]] 参照)。
config.tab_max_width = 28
-- fancy タブバーはタブ幅を「全幅 ÷ タブ数」でしか制限せず、右ステータスの領域を
-- 予約しないため、タブが増えるとステータスの左側が押し出されて消える。retro なら
-- tab_max_width が上限として効き、溢れる場合は均等に縮む。
config.use_fancy_tab_bar = false
config.warn_about_missing_glyphs = false
config.window_background_opacity = 0.96
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"

config.unix_domains = { { name = "unix" } }
config.default_gui_startup_args = { "connect", "unix" }

local ok, tls_conf = pcall(io.open, wezterm.home_dir .. "/.wezterm_tls.json")
if ok and tls_conf then
  local json = wezterm.json_parse(tls_conf:read "a")
  config.ssh_domains = json.ssh_domains
  -- TODO: fix this to work with unix
  -- config.tls_clients = json.tls_clients
  -- config.tls_servers = json.tls_servers
end

colors(config)
keys(config)
key_tables(config)
open_uri(config)
status_bar(config)
tab_title(config)

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

return config
