---@type Wezterm
local wezterm = require "wezterm"
local act = wezterm.action
local const = require "const"
local snatch = wezterm.plugin.require "https://github.com/delphinus/snatch.wezterm"

return function(config)
  local open_with = act.QuickSelectArgs {
    patterns = { const.regex.url },
    action = wezterm.action_callback(function(window, pane)
      local url = window:get_selection_text_for_pane(pane)
      wezterm.open_with(url)
    end),
  }

  -- editprompt (Claude Code への入力ペイン) は Cmd-e でトグルする。使わない間は
  -- 相方 (Claude Code) のペインを zoom して覆い隠すだけで、editprompt ペイン
  -- 自体はタブに残したままにする。nvim も denops も生きているので出し直しは
  -- 一瞬で済むし、隠している間は Claude Code がタブ一杯に広がる。
  --
  -- 当初はペインを別ワークスペースのウィンドウへ退避していたが、
  -- MuxPane:move_to_new_window でも wezterm cli move-pane-to-new-tab でも
  -- WezTerm ごと落ちた (2 回とも再現)。zoom ならペインの所属を一切動かさない。
  local editprompt_cells = 10
  -- zoom とフォーカス移動は対象を pane id で名指しできる CLI で行う。GUI から
  -- 起動されると PATH が最小限のことがあるので app bundle 内の実体を優先する。
  local wezterm_cli = wezterm.executable_dir .. "/wezterm"
  if #wezterm.glob(wezterm_cli) == 0 then
    wezterm_cli = "wezterm"
  end

  local spawn_editprompt = act.SplitPane {
    direction = "Down",
    command = {
      args = {
        const.fish,
        "-c",
        [=[
          set target_pane (wezterm cli list --format json | jq -r --argjson me $WEZTERM_PANE '[.[] | select(.pane_id == $me)][0].tab_id as $tab | [.[] | select(.tab_id == $tab and .pane_id != $me)][0].pane_id')
          if test -z "$target_pane" -o "$target_pane" = null
            echo "Could not find sibling pane"; read; exit 1
          end
          exec editprompt open -e 'nvim +"se laststatus=0" +startinsert' -E NVIM_APPNAME=nvim-dev/skkeleton -m wezterm -t $target_pane --always-copy
        ]=],
      },
    },
    size = { Cells = editprompt_cells },
  }

  -- CLI 呼び出しを順番に流す。background_child_process は投げっぱなしで順序を
  -- 保証しないので、前段の完了を待たせたいものは sh の && に任せる。
  local function cli_chain(cmds)
    local parts = {}
    for i, cmd in ipairs(cmds) do
      local words = { ("'%s' cli"):format(wezterm_cli) }
      for _, a in ipairs(cmd) do
        table.insert(words, tostring(a))
      end
      parts[i] = table.concat(words, " ")
    end
    wezterm.background_child_process { "/bin/sh", "-c", table.concat(parts, " && ") }
  end

  -- このタブの editprompt ペインと相方、zoom 中のペイン、ペイン数を返す。user var
  -- editprompt は nvim 側 (~/.config/nvim-dev/skkeleton/init.lua) が起動時に立てる。
  local function editprompt_layout(pane)
    local tab = pane:tab()
    if not tab then
      return nil
    end
    local ep, main, zoomed
    local infos = tab:panes_with_info()
    for _, info in ipairs(infos) do
      if info.is_zoomed then
        zoomed = info.pane:pane_id()
      end
      if info.pane:get_user_vars().editprompt then
        ep = info.pane:pane_id()
      elseif not main or info.pane:pane_id() == pane:pane_id() then
        -- 相方が複数居るときは、いま居るペインを優先して相方とみなす。
        main = info.pane:pane_id()
      end
    end
    return ep, main, zoomed, #infos
  end

  local toggle_editprompt = wezterm.action_callback(function(window, pane)
    local ep, main, zoomed = editprompt_layout(pane)
    if not ep then
      -- 初回。zoom したままだと split しても見えないので解除してから開く。
      window:perform_action(act.Multiple { act.SetPaneZoomState(false), spawn_editprompt }, pane)
    elseif not main then
      cli_chain { { "activate-pane", "--pane-id", ep } }
    elseif zoomed == main then
      -- 隠れている → 出して editprompt へフォーカスする。
      cli_chain {
        { "zoom-pane", "--pane-id", main, "--unzoom" },
        { "activate-pane", "--pane-id", ep },
      }
    else
      -- 出ている → 相方を zoom して覆い隠す。
      cli_chain {
        { "activate-pane", "--pane-id", main },
        { "zoom-pane", "--pane-id", main, "--zoom" },
      }
    end
  end)

  -- ⌘W。Claude Code 側を閉じるときは editprompt も道連れにする。片方だけ残ると
  -- タブが消えず、閉じるのに 2 回押す羽目になるため。ペインがちょうど 2 枚の
  -- ときだけにして、自分で足した 3 枚目を閉じただけで巻き添えにしないようにする。
  local close_pane = wezterm.action_callback(function(window, pane)
    local ep, _, _, count = editprompt_layout(pane)
    if ep and count == 2 and ep ~= pane:pane_id() then
      cli_chain { { "kill-pane", "--pane-id", ep } }
    end
    window:perform_action(act.CloseCurrentPane { confirm = false }, pane)
  end)

  -- 相方が居なくなって 1 枚だけ取り残された editprompt ペインを閉じる。上の
  -- close_pane が拾えるのは ⌘W の経路だけで、Claude Code 自身が終了した
  -- (/exit や ^D、クラッシュ) ときはこちらが始末する。editprompt ペインは必ず
  -- split で作られるので、タブに 1 枚きりなら相方を失った証拠とみなしてよい。
  local function reap_orphan_editprompt(window)
    local ok, mux_window = pcall(function()
      return window:mux_window()
    end)
    if not ok or not mux_window then
      return
    end
    for _, tab in ipairs(mux_window:tabs()) do
      local panes = tab:panes()
      if #panes == 1 and panes[1]:get_user_vars().editprompt then
        cli_chain { { "kill-pane", "--pane-id", panes[1]:pane_id() } }
      end
    end
  end

  wezterm.on("update-status", function(window)
    reap_orphan_editprompt(window)
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
            const.fish,
            "-c",
            ([[
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
    for line in text:gmatch "([^\n]*)\n?" do
      if line ~= "" or #lines > 0 then
        table.insert(lines, line)
      end
    end

    if #lines == 0 then
      wezterm.log_info "コピーする内容がありません"
      return
    end

    -- Find prompt lines (lines containing ❯❯❯ or ❮❮❮)
    -- Search from bottom to top
    local prompt_indices = {}
    for i = #lines, 1, -1 do
      if lines[i]:match "❯❯❯" or lines[i]:match "❮❮❮" then
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
      wezterm.log_info "直前の出力をコピーしました (最大50行)"
      return
    end

    -- Extract output between the last two prompts
    -- prompt_indices[1] is the most recent (bottom)
    -- prompt_indices[2] is the previous one
    local recent_prompt_idx = prompt_indices[1]
    local prev_prompt_idx = prompt_indices[2]

    -- Extract command from the prompt line
    local prompt_line = lines[prev_prompt_idx]
    local command = prompt_line:match "❯❯❯%s*(.*)$" or prompt_line:match "❮❮❮%s*(.*)$"

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
      wezterm.log_info "コピーする内容がありません"
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
    wezterm.background_child_process {
      "osascript",
      "-e",
      string.format('display notification "%s" with title "WezTerm"', message),
    }
  end)

  local paste_or_forward_image = wezterm.action_callback(function(window, pane)
    if pane:get_user_vars().editprompt then
      local success, stdout = wezterm.run_child_process { "osascript", "-e", "clipboard info" }
      if success and (stdout:match "PNGf" or stdout:match "TIFF") then
        local tab = pane:tab()
        for _, p in ipairs(tab:panes()) do
          if p:pane_id() ~= pane:pane_id() then
            -- PasteFrom はクリップボードのテキストしか運べないので、画像には使えない。
            -- Claude Code は ^V を受けると自分でクリップボードから画像を読むため、
            -- 生の ^V (0x16) をそのままペインへ流し込む。
            p:send_text "\x16"
            -- toast_notification だけだと通知センターの許可が無いときに黙って落ちるので、
            -- 上の copy_command_output と同じく osascript にもフォールバックする。
            local msg = "🖼 画像を Claude Code へ貼り付けました"
            pcall(function()
              window:toast_notification("WezTerm", msg, nil, 2000)
            end)
            wezterm.background_child_process {
              "osascript",
              "-e",
              string.format('display notification "%s" with title "WezTerm"', msg),
            }
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
    -- default: act.ActivateCopyMode
    { key = "[", mods = "CMD", action = snatch.action { shell = const.fish } },
    -- 再現精度の確認用。撮影前後のスクリーンショットを並べた画像を開く。
    { key = "[", mods = "CTRL|CMD", action = snatch.action { shell = const.fish, screenshot = true } },
    { key = "[", mods = "SHIFT|CMD", action = act.ActivateTabRelative(-1) },
    -- タブバーはドラッグでの並べ替えに対応していないので、タブの移動はここから。
    { key = "[", mods = "CTRL|SHIFT|CMD", action = act.MoveTabRelative(-1) },
    { key = "]", mods = "CMD", action = act.PasteFrom "Clipboard" },
    { key = "]", mods = "SHIFT|CMD", action = act.ActivateTabRelative(1) },
    { key = "]", mods = "CTRL|SHIFT|CMD", action = act.MoveTabRelative(1) },
    { key = "`", mods = "CMD", action = act.ActivateWindowRelative(1) },
    { key = "c", mods = "CMD", action = act.CopyTo "Clipboard" },
    { key = "c", mods = "SHIFT|CMD", action = act.CharSelect },
    { key = "e", mods = "CMD", action = toggle_editprompt },
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
    { key = "w", mods = "CMD", action = close_pane },
    { key = "y", mods = "CMD", action = copy_last_command_output },
    { key = "z", mods = "SHIFT|CMD", action = act.TogglePaneZoomState },
    { key = "Enter", mods = "CTRL", action = act.SendString "\x1b[13;5u" },
    { key = "Enter", mods = "CMD", action = act.SendString "\x1b[13;9u" },
    { key = "Enter", mods = "SHIFT", action = act.SendString "\x1b[13;2u" },
    -- HHKB の Fn+Enter は keypad_enter (macOS kVK_ANSI_KeypadEnter) として届く。
    -- kitty プロトコルの keypad-enter (PUA 57414) をそのまま送る。Neovim では
    -- <kEnter> として <CR>/<C-CR> と区別でき、editprompt が確定操作に割り当てる。
    -- fish 等 CSI u 対応シェルでは通常の Enter にフォールバックする。
    { key = "phys:KeypadEnter", action = act.SendString "\x1b[57414u" },
  }
end
