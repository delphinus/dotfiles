local wezterm = require "wezterm"
local act = wezterm.action
local const = require "const"

return function(config)
  local function tmux_or_fish()
    -- local _, stdout = wezterm.run_child_process { const.tmux_bin, "ls", "-F", "#{session_attached}" }
    -- local is_attached = wezterm.split_by_newlines(stdout)[1] == "1"
    local is_attached = true
    return is_attached and { const.fish_bin } or { const.tmux_run_bin }
  end

  local function spawn_window()
    wezterm.mux.spawn_window { args = tmux_or_fish() }
  end

  local function spawn_tab(window)
    window:mux_window():spawn_tab { args = tmux_or_fish() }
  end

  local open_with = act.QuickSelectArgs {
    patterns = { const.url_regex },
    action = wezterm.action_callback(function(window, pane)
      local url = window:get_selection_text_for_pane(pane)
      wezterm.open_with(url)
    end),
  }

  wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
    if button == "Left" then
      spawn_tab(window)
    elseif default_action then
      window:perform_action(default_action, pane)
    end
    return false
  end)

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
    { key = "j", mods = "SHIFT|CMD", action = act.ActivatePaneDirection "Next" },
    { key = "k", mods = "SHIFT|CMD", action = act.ActivatePaneDirection "Prev" },
    { key = "l", mods = "CMD", action = act.ShowDebugOverlay },
    { key = "m", mods = "CMD", action = act.Hide },
    { key = "n", mods = "CMD", action = wezterm.action_callback(spawn_window) },
    { key = "p", mods = "CMD", action = act.ActivateCommandPalette },
    { key = "q", mods = "CMD", action = act.QuitApplication },
    { key = "r", mods = "CMD", action = act.ReloadConfiguration },
    { key = "r", mods = "SHIFT|CMD", action = act.ActivateKeyTable { name = "resize_pane", one_shot = false } },
    { key = "s", mods = "SHIFT|CMD", action = act.SplitVertical { args = { const.fish_bin } } },
    { key = "t", mods = "CMD", action = wezterm.action_callback(spawn_tab) },
    { key = "u", mods = "CMD", action = act.QuickSelect },
    { key = "u", mods = "SHIFT|CMD", action = open_with },
    { key = "v", mods = "CMD", action = act.PasteFrom "Clipboard" },
    { key = "v", mods = "SHIFT|CMD", action = act.SplitHorizontal { args = { const.fish_bin } } },
    { key = "w", mods = "CMD", action = act.CloseCurrentTab { confirm = false } },
    { key = "z", mods = "SHIFT|CMD", action = act.TogglePaneZoomState },
  }
end
