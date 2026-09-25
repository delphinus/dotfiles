-- codediff の差分行を nvim-scrollview のスクロールバー上に出す。
--
-- codediff は Vim 本来の diff モードを使わず、独自の extmark (namespace
-- codediff-highlight に CodeDiffLineInsert / Delete / Move を張る) で差分を
-- 表現する。そのため scrollview の gitsigns 連携も組み込みのサイン群もこれを
-- 拾えず、バーだけが出て「バッファのどこに差分があるか」が分からない。ここで
-- その extmark を読み、scrollview のサイン群 (group = "codediff") へ流し込む。
--
-- 左 (original) には削除と移動、右 (modified) には追加と移動が出る。両側とも
-- 自分のバッファの extmark を見るだけなので、片側ずつ独立に正しく並ぶ。
--
-- サンドボックス (nvim-dev/codediff) とメイン config の両方から setup() を呼ぶ。

local M = {}

local group = "codediff"

-- 差分行ハイライト → スクロールバー上のサイン。symbol は 3 種とも同じで、色で
-- 区別する (codediff のガター記号 ＋ / － は 2 桁幅なのでバーには置けない)。
local kinds = {
  { line_hl = "CodeDiffLineInsert", hl = "CodeDiffScrollViewInsert", variant = "insert" },
  { line_hl = "CodeDiffLineDelete", hl = "CodeDiffScrollViewDelete", variant = "delete" },
  { line_hl = "CodeDiffLineMove", hl = "CodeDiffScrollViewMove", variant = "move" },
}

-- register_sign_spec() が返す「行番号のリストを入れる b: 変数」の名前 (line_hl 別)
local names = {}

-- codediff が差分行ハイライトを置く namespace (遅延ロードなので初回に解決する)
local cd_ns
local function get_cd_ns()
  if cd_ns == nil then
    local ok, m = pcall(require, "codediff.ui.highlights")
    cd_ns = (ok and m.ns_highlight) or false
  end
  return cd_ns or nil
end

-- 差分行の色は文字の下に敷く背景色なので暗い。そのまま前景色にするとバーの上で
-- ほとんど見えないため、色相を保ったまま最大チャンネルをここまで引き上げる。
local target = 0xcc

local function lift(color)
  local r, g, b = math.floor(color / 65536) % 256, math.floor(color / 256) % 256, color % 256
  local max = math.max(r, g, b)
  if max == 0 then
    return target * 65536 + target * 256 + target
  elseif max >= target then
    return color
  end
  local function chan(v)
    return math.min(255, math.floor(v * target / max + 0.5))
  end
  return chan(r) * 65536 + chan(g) * 256 + chan(b)
end

-- CodeDiffLine* は codediff のロード時 (= :CodeDiff の実行時) に定義されるので、
-- setup() の時点ではまだ無いことがある。差分行を見つけたときにも呼び直す。
local function define_hl()
  for _, kind in ipairs(kinds) do
    local hl = vim.api.nvim_get_hl(0, { name = kind.line_hl, link = false })
    if hl.bg or hl.ctermbg then
      vim.api.nvim_set_hl(0, kind.hl, { fg = hl.bg and lift(hl.bg) or nil, ctermfg = hl.ctermbg })
    end
  end
end

-- buf の差分行を集めて b: 変数へ入れる。実際に入れ替えたときだけ true を返す。
local function update(buf)
  local nsid = get_cd_ns()
  if not nsid or not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  local lines, seen, total = {}, {}, 0
  for _, kind in ipairs(kinds) do
    lines[kind.line_hl] = {}
  end
  for _, mk in ipairs(vim.api.nvim_buf_get_extmarks(buf, nsid, 0, -1, { details = true })) do
    local d = mk[4]
    local t = d and d.hl_group and lines[d.hl_group]
    if t then
      total = total + 1
      local last = (d.end_row or (mk[2] + 1)) - 1
      for row = mk[2], last do
        -- 同じ行に同種の extmark が重なることがある。行番号の重複はサインの
        -- 上限 (scrollview_signs_max_per_row) を無駄に食うので畳んでおく。
        local key = d.hl_group .. ":" .. row
        if not seen[key] then
          seen[key] = true
          t[#t + 1] = row + 1
        end
      end
    end
  end

  -- 差分ハイライトも内容も変わっていなければ b: も scrollview も触らない
  local sig = tostring(vim.b[buf].changedtick) .. "#" .. total
  if vim.b[buf].codediff_scrollview_sig == sig then
    return false
  end
  vim.b[buf].codediff_scrollview_sig = sig

  for _, kind in ipairs(kinds) do
    vim.b[buf][names[kind.line_hl]] = lines[kind.line_hl]
  end
  return true
end

function M.setup()
  local scrollview = require "scrollview"
  -- autoload/scrollview.vim (g:scrollview_* の既定値とサイン群の初期化) は
  -- plugin/scrollview.vim が timer_start(0) で呼ぶ。サンドボックスのように
  -- 起動中の -c "CodeDiff ..." からここへ来ると、まだ動いていないことがある。
  -- Initialize() は初回だけ autoload を読み込む no-op なので、先に叩いておく。
  vim.fn["scrollview#Initialize"]()

  scrollview.register_sign_group(group)
  for _, kind in ipairs(kinds) do
    names[kind.line_hl] = scrollview.register_sign_spec({
      extend = true,
      group = group,
      highlight = kind.hl,
      priority = 90,
      symbol = "┃",
      variant = kind.variant,
    }).name
  end
  scrollview.set_sign_group_state(group, true)

  define_hl()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("codediff-scrollview-signs", { clear = true }),
    -- codediff 自身の ColorScheme ハンドラが CodeDiffLine* を張り直した後で
    -- 読みたいので 1 tick 遅らせる。
    callback = function()
      vim.schedule(define_hl)
    end,
  })

  -- codediff は差分行ハイライトをウィンドウ生成のかなり後 (差分計算 → 最初の
  -- hunk へジャンプする頃) に置くため、scrollview 自身の refresh 契機 (主に
  -- WinScrolled) では間に合わない。codediff_bright_comment と同じ事情なので
  -- 同じイベント群で拾い、実際の再計算は changedtick + 差分行数のシグネチャで
  -- 間引く。
  vim.api.nvim_create_autocmd(
    { "BufWinEnter", "WinEnter", "TabEnter", "CursorMoved", "CursorHold", "WinScrolled", "TextChanged" },
    {
      group = vim.api.nvim_create_augroup("codediff-scrollview-signs-apply", { clear = true }),
      callback = function()
        local dirty = false
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_is_valid(win) and vim.w[win].codediff_restore then
            dirty = update(vim.api.nvim_win_get_buf(win)) or dirty
          end
        end
        if dirty then
          define_hl()
          -- WinScrolled の最中に同期 refresh を掛けると scrollview が作る
          -- フロートで入れ子になりうるので 1 tick 遅らせる。
          vim.schedule(function()
            vim.cmd "silent! ScrollViewRefresh"
          end)
        end
      end,
    }
  )
end

return M
