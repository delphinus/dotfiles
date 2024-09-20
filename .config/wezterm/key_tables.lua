local wezterm = require "wezterm"
local act = wezterm.action

return function(config)
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
        {
          Text = " TABLE: " .. name .. " ",
        },
        "ResetAttributes",
      })
    else
      window:set_right_status ""
    end
  end)

  config.key_tables = {
    copy_mode = {
      { key = ",", mods = "NONE", action = act.CopyMode "JumpReverse" },
      { key = "0", mods = "NONE", action = act.CopyMode "MoveToStartOfLine" },
      { key = "4", mods = "SHIFT", action = act.CopyMode "MoveToEndOfLineContent" },
      { key = "6", mods = "SHIFT", action = act.CopyMode "MoveToStartOfLineContent" },
      { key = ";", mods = "NONE", action = act.CopyMode "JumpAgain" },
      { key = "Enter", mods = "NONE", action = act.Multiple { { CopyTo = "Clipboard" }, { CopyMode = "Close" } } },
      { key = "Escape", mods = "NONE", action = act.CopyMode "Close" },
      { key = "Space", mods = "NONE", action = act.CopyMode { SetSelectionMode = "Cell" } },
      { key = "[", mods = "CMD", action = act.CopyMode "Close" },
      { key = "b", mods = "CTRL", action = act.CopyMode "PageUp" },
      { key = "b", mods = "NONE", action = act.CopyMode "MoveBackwardWord" },
      { key = "c", mods = "CTRL", action = act.CopyMode "Close" },
      { key = "d", mods = "CTRL", action = act.CopyMode { MoveByPage = 0.1 } },
      { key = "e", mods = "NONE", action = act.CopyMode "MoveForwardWordEnd" },
      { key = "f", mods = "CTRL", action = act.CopyMode "PageDown" },
      { key = "f", mods = "NONE", action = act.CopyMode { JumpForward = { prev_char = false } } },
      { key = "f", mods = "SHIFT", action = act.CopyMode { JumpBackward = { prev_char = false } } },
      { key = "g", mods = "NONE", action = act.CopyMode "MoveToScrollbackTop" },
      { key = "g", mods = "SHIFT", action = act.CopyMode "MoveToScrollbackBottom" },
      { key = "h", mods = "NONE", action = act.CopyMode "MoveLeft" },
      { key = "h", mods = "SHIFT", action = act.CopyMode "MoveToViewportTop" },
      { key = "j", mods = "NONE", action = act.CopyMode "MoveDown" },
      { key = "k", mods = "NONE", action = act.CopyMode "MoveUp" },
      { key = "l", mods = "NONE", action = act.CopyMode "MoveRight" },
      { key = "l", mods = "SHIFT", action = act.CopyMode "MoveToViewportBottom" },
      { key = "m", mods = "SHIFT", action = act.CopyMode "MoveToViewportMiddle" },
      { key = "o", mods = "NONE", action = act.CopyMode "MoveToSelectionOtherEndHoriz" },
      { key = "q", mods = "NONE", action = act.CopyMode "Close" },
      { key = "t", mods = "NONE", action = act.CopyMode { JumpForward = { prev_char = true } } },
      { key = "t", mods = "SHIFT", action = act.CopyMode { JumpBackward = { prev_char = true } } },
      { key = "u", mods = "CTRL", action = act.CopyMode { MoveByPage = -0.1 } },
      { key = "v", mods = "CTRL", action = act.CopyMode { SetSelectionMode = "Block" } },
      { key = "v", mods = "NONE", action = act.CopyMode { SetSelectionMode = "Cell" } },
      { key = "v", mods = "SHIFT", action = act.CopyMode { SetSelectionMode = "Line" } },
      { key = "w", mods = "NONE", action = act.CopyMode "MoveForwardWord" },
      { key = "y", mods = "NONE", action = act.Multiple { { CopyTo = "Clipboard" }, { CopyMode = "Close" } } },
    },

    resize_pane = {
      { key = "Escape", mods = "NONE", action = act.PopKeyTable },
      { key = "c", mods = "CTRL", action = act.PopKeyTable },
      { key = "h", mods = "NONE", action = act.AdjustPaneSize { "Left", 1 } },
      { key = "h", mods = "SHIFT", action = act.AdjustPaneSize { "Left", 10 } },
      { key = "j", mods = "NONE", action = act.AdjustPaneSize { "Down", 1 } },
      { key = "j", mods = "SHIFT", action = act.AdjustPaneSize { "Down", 10 } },
      { key = "k", mods = "NONE", action = act.AdjustPaneSize { "Up", 1 } },
      { key = "k", mods = "SHIFT", action = act.AdjustPaneSize { "Up", 5 } },
      { key = "l", mods = "NONE", action = act.AdjustPaneSize { "Right", 1 } },
      { key = "l", mods = "SHIFT", action = act.AdjustPaneSize { "Right", 5 } },
      { key = "q", mods = "NONE", action = act.PopKeyTable },
      { key = "r", mods = "SHIFT|CMD", action = act.PopKeyTable },
    },
  }
end
