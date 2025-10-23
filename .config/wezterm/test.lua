---@type Wezterm
local wezterm = require "wezterm"
local config = wezterm.config_builder()
config.unix_domains = { { name = "unix" } }
config.keys = {
  {
    key = "e",
    mods = "CMD",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(
        wezterm.action.SplitPane {
          direction = "Down",
          command = {
            args = {
              "sh",
              "-c",
              ([[
                echo "WEZTERM_PANE: $WEZTERM_PANE";
                echo "pane_id: %d";
                sleep 100;
              ]]):format(pane:pane_id()),
            },
          },
          size = { Cells = 10 },
        },
        pane
      )
    end),
  },
}
return config
