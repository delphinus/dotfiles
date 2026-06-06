---@type Wezterm
local wezterm = require "wezterm"
local ProgressBar = require "progress_bar"

local progress_bar = ProgressBar.new(8)

-- Claude Code の状態に応じたタブ背景色。claude-code-hooks tabcolor が各ペインの
-- user var claude_state をセットし、ここでタブ内の全ペインを走査して塗る。
-- 値が無い / "default" のときは塗らない。
local STATE_BG = {
  startup = "#7dcfff", -- 起動時
  thinking = "#bb9af7", -- 思考中
  idle = "#9ece6a", -- 待機中
  waiting = "#e0af68", -- 入力待ち
}
local STATE_FG = "#1a1b26" -- 塗ったときの前景 (暗色)

-- タブ内のいずれかのペインに claude_state が立っていれば、その色を返す。
-- (claude のペインがアクティブとは限らないので active_pane だけ見ない)
local function claude_bg(tab)
  for _, p in ipairs(tab.panes) do
    local uv = p.user_vars
    local s = uv and uv.claude_state
    if s and STATE_BG[s] then
      return STATE_BG[s]
    end
  end
  return nil
end

local function tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  local panes = tab_info.panes
  if not panes or #panes <= 1 then
    return tab_info.active_pane.title
  end
  local titles = {}
  local seen = {}
  for _, pane in ipairs(panes) do
    local t = pane.title
    if t and #t > 0 and not seen[t] then
      seen[t] = true
      table.insert(titles, t)
    end
  end
  return table.concat(titles, " | ")
end

local PCT_GLYPHS = {
  wezterm.nerdfonts.md_circle_slice_1,
  wezterm.nerdfonts.md_circle_slice_2,
  wezterm.nerdfonts.md_circle_slice_3,
  wezterm.nerdfonts.md_circle_slice_4,
  wezterm.nerdfonts.md_circle_slice_5,
  wezterm.nerdfonts.md_circle_slice_6,
  wezterm.nerdfonts.md_circle_slice_7,
  wezterm.nerdfonts.md_circle_slice_8,
}
local function pct_glyph(pct)
  local slot = math.floor(pct / 12)
  return PCT_GLYPHS[slot + 1]
end

return function(config)
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local progress = tab.active_pane.progress or "None"
    local title = tab_title(tab)

    local bg = claude_bg(tab)

    local elements = {}
    if bg then
      table.insert(elements, { Background = { Color = bg } })
      table.insert(elements, { Foreground = { Color = STATE_FG } })
    end
    table.insert(elements, { Text = string.format("%d: ", tab.tab_index + 1) })

    if progress ~= "None" then
      local color = config.colors.ansi[3]
      local status
      if progress.Percentage ~= nil then
        -- status = string.format("%d%%", progress.Percentage)
        status = progress_bar:render(progress.Percentage / 100)
      elseif progress.Error ~= nil then
        -- status = string.format("%d%%", progress.Error)
        status = pct_glyph(progress.Error)
        color = config.colors.ansi[2]
      elseif progress == "Indeterminate" then
        status = "~"
      else
        status = wezterm.serde.json_encode(progress)
      end

      table.insert(elements, { Foreground = { Color = color } })
      table.insert(elements, { Text = status })
      table.insert(elements, { Foreground = bg and { Color = STATE_FG } or "Default" })
    end

    table.insert(elements, { Text = " " .. title .. " " })

    return elements
  end)
end
