---@type Wezterm
local wezterm = require "wezterm"

local function focus_editprompt_pane(window)
  local tab = window:active_tab()
  if not tab then return end
  local panes = tab:panes_with_info()
  if #panes < 2 then return end

  local editprompt_info
  for _, info in ipairs(panes) do
    if (info.pane:get_user_vars().editprompt or "") ~= "" then
      editprompt_info = info
      break
    end
  end
  if not editprompt_info then return end
  if window:active_pane():pane_id() == editprompt_info.pane:pane_id() then return end

  for _, info in ipairs(panes) do
    if info.pane:pane_id() ~= editprompt_info.pane:pane_id()
        and info.top < editprompt_info.top then
      editprompt_info.pane:activate()
      return
    end
  end
end

return function()
  wezterm.on("window-focus-changed", function(window)
    if window:is_focused() then
      focus_editprompt_pane(window)
    end
  end)

  local last_active_tab_per_window = {}
  wezterm.on("update-status", function(window)
    local wid = window:window_id()
    local tab = window:active_tab()
    if not tab then return end
    local tid = tab:tab_id()
    if last_active_tab_per_window[wid] ~= tid then
      last_active_tab_per_window[wid] = tid
      focus_editprompt_pane(window)
    end
  end)
end
