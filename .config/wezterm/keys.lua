local wezterm = require "wezterm"
local act = wezterm.action
local const = require "const"

return function(config)
  local open_with = act.QuickSelectArgs {
    patterns = { const.url_regex },
    action = wezterm.action_callback(function(window, pane)
      local url = window:get_selection_text_for_pane(pane)
      wezterm.open_with(url)
    end),
  }

  config.keys = {
    { key = "-", mods = "CMD", action = act.DecreaseFontSize },
    { key = "0", mods = "CMD", action = act.ResetFontSize },
    { key = "0", mods = "SHIFT|CMD", action = act.ResetFontAndWindowSize },
    { key = "1", mods = "CMD", action = act.ActivateTab(0) },
    { key = "2", mods = "CMD", action = act.ActivateTab(1) },
    { key = "3", mods = "CMD", action = act.ActivateTab(2) },
    { key = "4", mods = "CMD", action = act.ActivateTab(3) },
    { key = "5", mods = "CMD", action = act.ActivateTab(4) },
    { key = "6", mods = "CMD", action = act.ActivateTab(5) },
    { key = "7", mods = "CMD", action = act.ActivateTab(6) },
    { key = "8", mods = "CMD", action = act.ActivateTab(7) },
    { key = "9", mods = "CMD", action = act.ActivateTab(8) },
    { key = "=", mods = "CMD", action = act.IncreaseFontSize },
    { key = "[", mods = "CMD", action = act.ActivateCopyMode },
    { key = "[", mods = "SHIFT|CMD", action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "SHIFT|CMD", action = act.ActivateTabRelative(1) },
    { key = "`", mods = "CMD", action = act.ActivateWindowRelative(1) },
    { key = "c", mods = "CMD", action = act.CopyTo "Clipboard" },
    { key = "c", mods = "SHIFT|CMD", action = act.CharSelect },
    { key = "f", mods = "CMD", action = act.Search { CaseSensitiveString = "" } },
    { key = "f", mods = "SHIFT|CMD", action = act.ToggleFullScreen },
    { key = "h", mods = "CMD", action = act.HideApplication },
    { key = "j", mods = "CMD", action = act.ActivatePaneDirection "Next" },
    { key = "k", mods = "CMD", action = act.ActivatePaneDirection "Prev" },
    { key = "l", mods = "CMD", action = act.ShowDebugOverlay },
    { key = "m", mods = "CMD", action = act.Hide },
    { key = "n", mods = "CMD", action = act.SpawnWindow },
    { key = "p", mods = "CMD", action = act.ActivateCommandPalette },
    { key = "q", mods = "CMD", action = act.QuitApplication },
    { key = "r", mods = "CMD", action = act.ReloadConfiguration },
    { key = "r", mods = "SHIFT|CMD", action = act.ActivateKeyTable { name = "resize_pane", one_shot = false } },
    { key = "s", mods = "CMD", action = act.SplitVertical { args = { const.fish } } },
    { key = "t", mods = "CMD", action = act.SpawnTab "CurrentPaneDomain" },
    { key = "u", mods = "CMD", action = act.QuickSelect },
    { key = "u", mods = "SHIFT|CMD", action = open_with },
    { key = "v", mods = "CMD", action = act.PasteFrom "Clipboard" },
    { key = "v", mods = "SHIFT|CMD", action = act.SplitHorizontal { args = { const.fish } } },
    { key = "w", mods = "CMD", action = act.CloseCurrentTab { confirm = false } },
    { key = "z", mods = "SHIFT|CMD", action = act.TogglePaneZoomState },
  }
end
