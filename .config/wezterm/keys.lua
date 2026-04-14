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
    window:perform_action(
      act.SplitPane {
        direction = "Down",
        command = {
          args = {
            const.fish, "-c", [=[
              set target_pane (wezterm cli list --format json | jq -r --argjson me $WEZTERM_PANE '[.[] | select(.pane_id == $me)][0].tab_id as $tab | [.[] | select(.tab_id == $tab and .pane_id != $me)][0].pane_id')
              if test -z "$target_pane" -o "$target_pane" = null
                echo "Could not find sibling pane"; read; exit 1
              end
              exec editprompt open -e 'nvim +"se laststatus=0" +startinsert' -E NVIM_APPNAME=nvim-dev/skkeleton -m wezterm -t $target_pane --always-copy
            ]=],
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

  local pstree_script = wezterm.home_dir .. "/git/github.com/delphinus/dotfiles/bin/simple-pstree"
  local show_pstree = wezterm.action_callback(function(window, pane)
    window:perform_action(
      act.SplitPane {
        direction = "Right",
        command = {
          args = {
            const.fish, "-c", ([[
              set my_pane $WEZTERM_PANE
              set tty (wezterm cli list --format json | python3 -c "
import sys, json
d = json.load(sys.stdin)
me = [p for p in d if p['pane_id'] == int(sys.argv[1])][0]
sibs = [p for p in d if p['tab_id'] == me['tab_id'] and p['pane_id'] != me['pane_id'] and p.get('tty_name')]
print(sibs[0]['tty_name'].replace('/dev/','') if sibs else '')
" $my_pane)
              if test -z "$tty"
                echo "Could not find sibling pane tty"; read; exit 1
              end
              set pid (ps -o pid= -t $tty | sort -n | head -1 | string trim)
              if test -z "$pid"
                echo "Could not find PID for tty $tty"; read; exit 1
              end
              exec %s $pid
            ]]):format(pstree_script),
          },
        },
        size = { Cells = 60 },
      },
      pane
    )
  end)

  local copy_last_command_output = wezterm.action_callback(function(window, pane)
    -- Get recent lines from scrollback to find prompt patterns
    -- Use get_logical_lines_as_text to avoid wrapping issues
    local max_lines = 500
    local text = pane:get_logical_lines_as_text(max_lines)

    -- Split into lines
    local lines = {}
    for line in text:gmatch("([^\n]*)\n?") do
      if line ~= "" or #lines > 0 then
        table.insert(lines, line)
      end
    end

    if #lines == 0 then
      wezterm.log_info("コピーする内容がありません")
      return
    end

    -- Find prompt lines (lines containing ❯❯❯ or ❮❮❮)
    -- Search from bottom to top
    local prompt_indices = {}
    for i = #lines, 1, -1 do
      if lines[i]:match("❯❯❯") or lines[i]:match("❮❮❮") then
        table.insert(prompt_indices, i)
        if #prompt_indices >= 2 then
          break
        end
      end
    end

    if #prompt_indices < 2 then
      -- If we can't find 2 prompts, copy last 50 lines as fallback
      local fallback_start = math.max(1, #lines - 50)
      local fallback_lines = {}
      for i = fallback_start, #lines do
        table.insert(fallback_lines, lines[i])
      end
      local fallback_text = table.concat(fallback_lines, "\n")
      window:copy_to_clipboard(fallback_text)
      wezterm.log_info("直前の出力をコピーしました (最大50行)")
      return
    end

    -- Extract output between the last two prompts
    -- prompt_indices[1] is the most recent (bottom)
    -- prompt_indices[2] is the previous one
    local recent_prompt_idx = prompt_indices[1]
    local prev_prompt_idx = prompt_indices[2]

    -- Extract command from the prompt line
    local prompt_line = lines[prev_prompt_idx]
    local command = prompt_line:match("❯❯❯%s*(.*)$") or prompt_line:match("❮❮❮%s*(.*)$")

    -- Output lines are from the line after prev_prompt to the line before recent_prompt
    local output_start = prev_prompt_idx + 1
    local output_end = recent_prompt_idx - 1

    -- Build the result: command + output
    local result_lines = {}

    -- Add command if it exists
    if command and command ~= "" then
      table.insert(result_lines, command)
    end

    -- Add output lines
    if output_end >= output_start then
      for i = output_start, output_end do
        table.insert(result_lines, lines[i])
      end
    end

    if #result_lines == 0 then
      wezterm.log_info("コピーする内容がありません")
      return
    end

    local result_text = table.concat(result_lines, "\n")
    window:copy_to_clipboard(result_text)

    local line_count = #result_lines
    local line_info = line_count == 1 and "1行" or line_count .. "行"
    local message = "✓ コマンドと出力をコピーしました (" .. line_info .. ")"

    wezterm.log_info(message)

    -- Try multiple notification methods
    -- 1. Try WezTerm's built-in toast notification
    pcall(function()
      window:toast_notification("WezTerm", message, nil, 2000)
    end)

    -- 2. Fallback: Use macOS notification center
    wezterm.background_child_process({
      "osascript",
      "-e",
      string.format('display notification "%s" with title "WezTerm"', message),
    })
  end)

  local screen_copy = wezterm.action_callback(function(window, pane)
    local dims = pane:get_dimensions()
    local total_rows = dims.scrollback_rows + dims.viewport_rows
    local text = pane:get_logical_lines_as_text(total_rows)

    -- Write to temp file
    local tmpfile = "/tmp/wezterm-copy-" .. tostring(os.time()) .. "-" .. tostring(pane:pane_id())
    local f = io.open(tmpfile, "w")
    if not f then
      wezterm.log_error "Failed to create temp file for screen copy"
      return
    end
    f:write(text)
    f:close()

    -- Count lines in the captured text
    local total_lines = 1
    for _ in text:gmatch "\n" do
      total_lines = total_lines + 1
    end

    -- Calculate approximate viewport top line
    local scroll_offset = 0
    if dims.scrollback_rows and dims.physical_top and dims.scrollback_top then
      scroll_offset = dims.scrollback_rows - (dims.physical_top - dims.scrollback_top)
    end
    local viewport_line = math.max(1, total_lines - dims.viewport_rows - scroll_offset)

    local caller_tab_idx = 0
    for _, info in ipairs(window:mux_window():tabs_with_info()) do
      if info.is_active then
        caller_tab_idx = info.index
        break
      end
    end

    window:perform_action(
      act.SpawnCommandInNewTab {
        domain = "CurrentPaneDomain",
        args = {
          const.fish, "-c", ([=[
            set -x NVIM_APPNAME nvim-dev/wezterm-copy
            set -x WEZTERM_COPY_LINE %d
            nvim -R %s
            wezterm cli activate-tab --tab-index %d
          ]=]):format(viewport_line, tmpfile, caller_tab_idx),
        },
      },
      pane
    )
  end)

  local paste_or_forward_image = wezterm.action_callback(function(window, pane)
    if pane:get_user_vars().editprompt then
      local success, stdout = wezterm.run_child_process { "osascript", "-e", "clipboard info" }
      if success and (stdout:match "PNGf" or stdout:match "TIFF") then
        local tab = pane:tab()
        for _, p in ipairs(tab:panes()) do
          if p:pane_id() ~= pane:pane_id() then
            window:perform_action(act.PasteFrom "Clipboard", p)
            return
          end
        end
      end
    end
    window:perform_action(act.PasteFrom "Clipboard", pane)
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
    { key = "f", mods = "CMD", action = act.Search { CaseSensitiveString = "" } },
    { key = "f", mods = "SHIFT|CMD", action = act.ToggleFullScreen },
    { key = "h", mods = "CMD", action = act.HideApplication },
    { key = "h", mods = "SHIFT|CMD", action = act.Search { Regex = "[a-f0-9]{6,}" } },
    { key = "i", mods = "CMD", action = show_pstree },
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
    { key = "v", mods = "CMD", action = paste_or_forward_image },
    { key = "v", mods = "SHIFT|CMD", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "w", mods = "CMD", action = act.CloseCurrentPane { confirm = false } },
    { key = "y", mods = "CMD", action = copy_last_command_output },
    { key = "y", mods = "SHIFT|CMD", action = screen_copy },
    { key = "z", mods = "SHIFT|CMD", action = act.TogglePaneZoomState },
    { key = "Enter", mods = "CTRL", action = act.SendString "\x1b[13;5u" },
    { key = "Enter", mods = "CMD", action = act.SendString "\x1b[13;9u" },
  }
end
