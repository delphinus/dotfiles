-- タブバーの幅の配分を status_bar.lua と tab_title.lua で共有する。
--
-- WezTerm はタブの幅を決めるときに右ステータスの領域を予約しない
-- (wezterm-gui/src/tabbar.rs の available_cells がタブ数と新規タブボタンしか
-- 引いていない)。溢れた右ステータスは remove_cell(0) で左から削られるので、
-- タブが増えると battery や TimeMachine の表示が黙って消える。
--
-- format-tab-title はウィンドウ幅も右ステータスの幅も受け取らないため、
-- 両方を知っている update-status (status_bar.lua) 側から実測値をここへ書き、
-- tab_title.lua がそれを見て自分でタブ幅を絞る。
local M = {
  cols = nil, -- ウィンドウの桁数。まだ measure していなければ nil
  status_width = 0, -- 右ステータスが占める桁数
}

-- 新規タブボタン " + " の分。
local NEW_TAB_WIDTH = 3
-- タブとステータスの間に必ず残す余白。
local GUTTER = 2
-- タブをこれ以上は狭めない。ここまで詰まったらステータスが削られるのは諦める。
local MIN_TAB_WIDTH = 10

function M.publish(cols, status_width)
  M.cols = cols
  M.status_width = status_width
end

-- タブ 1 枚に割り当ててよい桁数。ceiling (= tab_max_width) を超えない範囲で、
-- ステータスを削らずに済む幅を返す。実測値がまだ無ければ ceiling をそのまま返す。
function M.tab_width(tab_count, ceiling)
  if not M.cols or tab_count < 1 then
    return ceiling
  end
  local usable = M.cols - M.status_width - NEW_TAB_WIDTH - GUTTER
  return math.max(math.min(math.floor(usable / tab_count), ceiling), MIN_TAB_WIDTH)
end

return M
