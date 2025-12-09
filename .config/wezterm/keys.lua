---@type Wezterm
local wezterm = require "wezterm"
local act = wezterm.action
local const = require "const"

return function(config)
  local open_with = act.QuickSelectArgs {
    patterns = { const.regex.url },
    action = wezterm.action_callback(function(window, pane)
      local url = window:get_selection_text_for_pane(pane)
      wezterm.open_with(url)
    end),
  }

  local editprompt = wezterm.action_callback(function(window, pane)
    local gui_pane_id = pane:pane_id()
    local cli_pane_id = gui_pane_id

    -- multiplexing環境の判定
    local domain = pane:get_domain_name()
    if domain and domain ~= "local" then
      -- unix domainなどのmultiplexing環境では-1
      cli_pane_id = gui_pane_id - 1
    end

    window:perform_action(
      act.SplitPane {
        direction = "Down",
        command = {
          args = {
            "/opt/homebrew/bin/fish",
            "-c",
            ([[editprompt open -e 'nvim +"se laststatus=0" +startinsert' -E NVIM_APPNAME=nvim-dev/skkeleton -m wezterm -t %d --always-copy]]):format(
              cli_pane_id
            ),
          },
        },
        size = { Cells = 10 },
      },
      pane
    )
  end)

  local test = wezterm.action_callback(function(window, pane)
    window:perform_action(
      act.SplitPane {
        direction = "Down",
        command = {
          args = {
            "/opt/homebrew/bin/fish",
            "-c",
            "echo 'WEZTERM_PANE env var: '$WEZTERM_PANE ; sleep 5",
          },
        },
        size = { Cells = 10 },
      },
      pane
    )
  end)

  local move_to_new_tab = wezterm.action_callback(function(_, pane)
    pane:move_to_new_tab():activate()
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
    { key = "!", mods = "SHIFT|CMD", action = move_to_new_tab },
    { key = "=", mods = "CMD", action = act.IncreaseFontSize },
    { key = "[", mods = "CMD", action = act.ActivateCopyMode },
    { key = "[", mods = "SHIFT|CMD", action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "CMD", action = act.PasteFrom "Clipboard" },
    { key = "]", mods = "SHIFT|CMD", action = act.ActivateTabRelative(1) },
    { key = "`", mods = "CMD", action = act.ActivateWindowRelative(1) },
    { key = "c", mods = "CMD", action = act.CopyTo "Clipboard" },
    { key = "c", mods = "SHIFT|CMD", action = act.CharSelect },
    { key = "e", mods = "CMD", action = editprompt },
    { key = "e", mods = "SHIFT|CMD", action = test },
    { key = "f", mods = "CMD", action = act.Search { CaseSensitiveString = "" } },
    { key = "f", mods = "SHIFT|CMD", action = act.ToggleFullScreen },
    { key = "h", mods = "CMD", action = act.HideApplication },
    { key = "h", mods = "SHIFT|CMD", action = act.Search { Regex = "[a-f0-9]{6,}" } },
    { key = "j", mods = "CMD", action = act.ActivatePaneDirection "Next" },
    { key = "j", mods = "SHIFT|CMD", action = act.ScrollToPrompt(1) },
    { key = "k", mods = "CMD", action = act.ActivatePaneDirection "Prev" },
    { key = "k", mods = "SHIFT|CMD", action = act.ScrollToPrompt(-1) },
    { key = "l", mods = "CMD", action = act.ShowDebugOverlay },
    { key = "m", mods = "CMD", action = act.Hide },
    { key = "n", mods = "CMD", action = act.SpawnWindow },
    { key = "p", mods = "CMD", action = act.ActivateCommandPalette },
    { key = "q", mods = "CMD", action = act.QuitApplication },
    { key = "r", mods = "CMD", action = act.ActivateKeyTable { name = "resize_pane", one_shot = false } },
    { key = "r", mods = "SHIFT|CMD", action = act.ReloadConfiguration },
    { key = "s", mods = "CMD", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = "t", mods = "CMD", action = act.SpawnTab "CurrentPaneDomain" },
    { key = "u", mods = "CMD", action = act.QuickSelect },
    { key = "u", mods = "SHIFT|CMD", action = open_with },
    { key = "v", mods = "CMD", action = act.PasteFrom "Clipboard" },
    { key = "v", mods = "SHIFT|CMD", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "w", mods = "CMD", action = act.CloseCurrentPane { confirm = false } },
    { key = "z", mods = "SHIFT|CMD", action = act.TogglePaneZoomState },
  }
end
