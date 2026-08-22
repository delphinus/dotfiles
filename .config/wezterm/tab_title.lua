---@type Wezterm
local wezterm = require "wezterm"
local ProgressBar = require "progress_bar"
local metrics = require "tab_bar_metrics"

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
local FG_DARK = "#1a1b26" -- 明るい背景に乗せる前景 (暗色)
local FG_LIGHT = "#c0caf5" -- 暗い背景に乗せる前景 (明色)

-- 非アクティブタブの背景をどれだけ暗くするか (0..1, 大きいほど暗い)。
local INACTIVE_DARKEN = 0.25

-- 各タブを角丸のチップとして描く。半円のキャップをタブ自身の背景色でタブバーの
-- 地の上に置くと、チップの左右が丸まって見え、タブ同士の間に地の色の隙間ができる。
-- KevinSilvester/wezterm-config と同じ手法 (出典は wezterm#628)。
local LEFT_CAP = wezterm.nerdfonts.ple_left_half_circle_thick
local RIGHT_CAP = wezterm.nerdfonts.ple_right_half_circle_thick

-- タブ内のいずれかのペインに claude_state が立っていれば、その状態色 (hex) を返す。
-- (claude のペインがアクティブとは限らないので active_pane だけ見ない)
local function claude_hex(tab)
  for _, p in ipairs(tab.panes) do
    local uv = p.user_vars
    local s = uv and uv.claude_state
    if s and STATE_BG[s] then
      return STATE_BG[s]
    end
  end
  return nil
end

-- 状態色を受け取り、アクティブなら原色のまま、非アクティブなら暗くして返す。
-- あわせて、加工後の背景の明度から読みやすい前景色を選ぶ。
local function claude_colors(tab)
  local hex = claude_hex(tab)
  if not hex then
    return nil, nil
  end
  local c = wezterm.color.parse(hex)
  if not tab.is_active then
    c = c:darken(INACTIVE_DARKEN)
  end
  local _, _, l = c:hsla()
  local fg = l > 0.4 and FG_DARK or FG_LIGHT
  return tostring(c), fg
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

-- 進捗の表示文字列と色。進捗が無ければ nil。
local function progress_status(tab, palette)
  local progress = tab.active_pane.progress or "None"
  if progress == "None" then
    return nil, nil
  end
  if progress.Percentage ~= nil then
    return progress_bar:render(progress.Percentage / 100), palette.ansi[3]
  elseif progress.Error ~= nil then
    return pct_glyph(progress.Error), palette.ansi[2]
  elseif progress == "Indeterminate" then
    return "~", palette.ansi[3]
  end
  return wezterm.serde.json_encode(progress), palette.ansi[3]
end

-- チップの背景と前景。claude_state が立っていればその状態色を、無ければ配色の
-- active_tab / inactive_tab を使う。
local function chip_colors(tab, palette)
  local bg, fg = claude_colors(tab)
  if bg then
    return bg, fg
  end
  local c = tab.is_active and palette.tab_bar.active_tab or palette.tab_bar.inactive_tab
  return c.bg_color, c.fg_color
end

return function(config)
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local palette = config.resolved_palette
    local bar_bg = palette.tab_bar.background
    local chip_bg, chip_fg = chip_colors(tab, palette)

    local index = string.format("%d:", tab.tab_index + 1)
    local status, status_color = progress_status(tab, palette)

    -- チップ全体をこの幅に収める。max_width (= tabbar.rs が渡してくる上限) を
    -- 超えると後ろから機械的に切られて右キャップが消えるので、自分で削る。
    -- タブ数が多いときは metrics がステータスの分を差し引いた幅まで絞る。
    local width = metrics.tab_width(#tabs, max_width)
    local fixed = 2 + wezterm.column_width(index) + 1
    if status then
      fixed = fixed + 1 + wezterm.column_width(status)
    end
    local title = tab_title(tab)
    local budget = math.max(width - fixed, 1)
    if wezterm.column_width(title) > budget then
      title = wezterm.truncate_right(title, budget - 1) .. "…"
    end

    local elements = {
      -- 左キャップ。地の色の上にチップ色で半円を描く。
      { Background = { Color = bar_bg } },
      { Foreground = { Color = chip_bg } },
      { Text = LEFT_CAP },
      { Background = { Color = chip_bg } },
      { Foreground = { Color = chip_fg } },
    }
    if tab.is_active then
      table.insert(elements, { Attribute = { Intensity = "Bold" } })
    end
    table.insert(elements, { Text = index })
    if status then
      table.insert(elements, { Foreground = { Color = status_color } })
      table.insert(elements, { Text = " " .. status })
      table.insert(elements, { Foreground = { Color = chip_fg } })
    end
    table.insert(elements, { Text = " " .. title })
    -- 右キャップ。前景と背景を入れ替えて閉じる。
    table.insert(elements, { Background = { Color = bar_bg } })
    table.insert(elements, { Foreground = { Color = chip_bg } })
    table.insert(elements, { Text = RIGHT_CAP })

    return elements
  end)
end
