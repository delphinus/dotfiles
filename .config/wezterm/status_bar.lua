---@type Wezterm
local wezterm = require "wezterm"
local Battery = require "battery"
local Timemachine = require "timemachine"
local metrics = require "tab_bar_metrics"

-- 項目の区切り。地の色より一段明るいだけの細線にして、区切り自体は目立たせない。
local SEPARATOR = " │ "

-- 補助情報 (window:tab:pane) と区切り線の色。どちらも配色の暗い側から取る。
---@return string separator
---@return string muted
local function dim_colors(palette)
  local inactive = palette.tab_bar and palette.tab_bar.inactive_tab
  local separator = palette.brights and palette.brights[1] or (inactive and inactive.bg_color) or palette.ansi[1]
  local muted = inactive and inactive.fg_color or separator
  return separator, muted
end

-- 残量の深刻度に対応する前景色。
local function battery_color(palette, level)
  if level == "critical" then
    return palette.ansi[2]
  elseif level == "warn" then
    return palette.ansi[4]
  end
  return palette.ansi[3]
end

-- "08/24 11:11:32" ではなく "8/24 11:11:32" にする (%-m は使わず自前で削る)。
local function clock_text()
  return (wezterm.strftime("%m/%d %H:%M:%S"):gsub("^0", ""))
end

local function key_table(palette, window)
  local name = window:active_key_table()
  if not name then
    return {}
  end
  local bg = {
    copy_mode = palette.ansi[4],
    resize_pane = palette.ansi[6],
    search_mode = palette.ansi[7],
  }
  return {
    { Foreground = { Color = palette.ansi[1] } },
    { Background = { Color = bg[name] } },
    { Text = (" %s %s "):format(wezterm.nerdfonts.md_table, name) },
    "ResetAttributes",
  }
end

local function domain(palette)
  local type, path = wezterm.mux.get_domain():label():match "(.*) mux (.*)"
  return type == "SSH"
      and {
        { Foreground = { Color = palette.ansi[1] } },
        { Background = { Color = palette.ansi[3] } },
        { Text = (" %s %s "):format(wezterm.nerdfonts.md_console_network, path) },
      }
    or {}
end

return function(config)
  local battery = Battery.new()
  local timemachine = Timemachine.new()

  wezterm.on("update-status", function(window, pane)
    local palette = config.colors
    local separator, muted = dim_colors(palette)

    -- 左から順に並べる項目。text が nil のものは並べない。大事なものほど右へ置く
    -- (場所が無くなってタブに押されるのは左端なので、そちらから諦める)。
    local segments = {}
    local function add(color, text)
      if text then
        table.insert(segments, { color = color, text = text })
      end
    end

    add(
      muted,
      ("%s %d:%d:%d"):format(
        wezterm.nerdfonts.md_window_maximize,
        window:window_id(),
        window:active_tab():tab_id(),
        pane:pane_id()
      )
    )
    add(palette.ansi[2], timemachine:text())
    local bt, level = battery:text()
    add(battery_color(palette, level), bt)
    local meta = pane:get_metadata() or {}
    if meta.is_tardy then
      add(palette.ansi[7], ("%s %.2f"):format(wezterm.nerdfonts.md_airplane_clock, meta.since_last_response_ms / 1000))
    end
    add(palette.ansi[5], ("%s %s"):format(wezterm.nerdfonts.md_clock_outline, clock_text()))

    local elements = {
      { Background = { Color = palette.tab_bar.background } },
      { Text = " " },
    }
    for i, segment in ipairs(segments) do
      if i > 1 then
        table.insert(elements, { Foreground = { Color = separator } })
        table.insert(elements, { Text = SEPARATOR })
      end
      table.insert(elements, { Foreground = { Color = segment.color } })
      table.insert(elements, { Text = segment.text })
    end
    table.insert(elements, "ResetAttributes")
    -- キーテーブルと SSH ドメインは状態を強く示すものなので、他と違って
    -- 背景を塗ったチップのまま右端に並べる。
    for _, value in ipairs(key_table(palette, window)) do
      table.insert(elements, value)
    end
    for _, value in ipairs(domain(palette)) do
      table.insert(elements, value)
    end
    table.insert(elements, { Background = { Color = palette.tab_bar.background } })
    table.insert(elements, { Text = " " })

    -- タブ幅を決めるのに要るので、確定したステータスの幅とウィンドウの桁数を
    -- tab_title.lua へ渡す ([[tab_bar_metrics]] 参照)。
    local status_width = 0
    for _, e in ipairs(elements) do
      if type(e) == "table" and e.Text then
        status_width = status_width + wezterm.column_width(e.Text)
      end
    end
    local ok, size = pcall(function()
      return window:active_tab():get_size()
    end)
    metrics.publish(ok and size and size.cols or nil, status_width)

    window:set_right_status(wezterm.format(elements))
  end)
end
