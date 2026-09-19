-- Shared blink.cmp helpers and provider configs reused by both the main
-- nvim config and the nvim-dev/skkeleton sub-config (editprompt / gitcommit).
-- The dev config prepends this file's directory to package.path so it can
-- `require("blink_shared")` the same module the main config uses.

local M = {}

-- True if the token before cursor starts with a path-marker (/, ~/, ./, ../,
-- $VAR/, ${VAR}/). Mirrors blink.cmp の path source の lib.dirname() and
-- intentionally excludes URL/namespace strings like "github.com/foo/bar".
function M.in_path_context()
  if vim.in_fast_event() then
    return false
  end
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local last = (line:sub(1, col):match "(%S+)$" or ""):gsub("^[\"'`]", "")
  return last:match "^/" ~= nil
    or last:match "^~/" ~= nil
    or last:match "^%.%.?/" ~= nil
    or last:match "^%$[%w_]+/" ~= nil
    or last:match "^%$%{[%w_]+%}/" ~= nil
end

local function ghe_hosts()
  if not vim.env.GITHUB_ENTERPRISE_HOST then
    return {}
  end
  return vim.split(vim.env.GITHUB_ENTERPRISE_HOST, ",", { trimempty = true })
end

function M.matched_ghe_host()
  local hosts = ghe_hosts()
  if #hosts == 0 then
    return nil
  end
  local ok, utils = pcall(require, "blink-cmp-git.utils")
  if not ok then
    return nil
  end
  local url = utils.get_repo_remote_url()
  if not url or url == "" then
    return nil
  end
  for _, host in ipairs(hosts) do
    if url:find(host, 1, true) then
      return host
    end
  end
  return nil
end

-- Wrap blink-cmp-git's default github feature so that GHE hosts listed in
-- $GITHUB_ENTERPRISE_HOST are recognized as enabled and `gh` is invoked with
-- --hostname to target the right instance.
function M.github_feature_override(feature)
  return {
    enable = function()
      local default = require("blink-cmp-git.default.github")[feature]
      return default.enable() or M.matched_ghe_host() ~= nil
    end,
    get_command_args = function(command, token)
      local default = require("blink-cmp-git.default.github")[feature]
      local args = default.get_command_args(command, token)
      local host = M.matched_ghe_host()
      if host and command ~= "curl" then
        table.insert(args, "--hostname")
        table.insert(args, host)
      end
      return args
    end,
  }
end

-- Per-source icons for the menu's kind_icon column. Sources not listed here
-- keep blink.cmp's default kind icon — LSP 等は項目ごとの kind (Function /
-- Variable …) が出るので、source 単位のアイコンで潰さない。
--
-- 幅はすべて 2 桁になる (cellwidths の設定で U+F0000 以降が 2、sfmono_square
-- プリセットで U+E000 台も 2)。以前の ASCII 1 文字から 1 桁広がるが、LSP 補完
-- では元々 kind アイコンで 2 桁だったので、そちらに揃う形になる。
-- グリフ名は Nerd Fonts のもの。手元の SF Mono Square に収録済みであることは
-- フォントの cmap を読んで確認した。
M.source_icons = {
  pane = "󰞷", -- md-console_line
  ripgrep = "󰍉", -- md-magnify
  ghq = "", -- oct-repo
  digraphs = "󰌌", -- md-keyboard
  git = "", -- dev-git (ghq と系統を変えて見分けを付ける)
  dictionary = "󰘝", -- md-book_alphabet
  emoji = "󰇲", -- md-emoticon_outline
  nerdfont = "", -- cod-symbol_misc
  fish = "󰈺", -- md-fish
  skkeleton = "󱌱", -- md-ideogram_cjk (送りなし。送りありは下の SKK_OKURIARI_ICON)
}

-- 送りあり候補だけ別のグリフを出す。送りなし (漢字だけで確定する) と送りあり
-- (漢字 + 送り仮名) が同じ表層形になることがあり (「あたり /当り/」と
-- 「あたr /当;大当り/」→ どちらも「当り」)、読みが違うので重複排除も効かない。
-- 左端の形と、読み側の送りあり記法 (skk_readings) の 2 つで区別する。
local SKK_OKURIARI_ICON = "󱌴" -- md-syllabary_hiragana

-- Per-source highlight group used both for the kind_icon override and the
-- source_name column. Reuses Vim standard syntax groups so colors track the
-- active colorscheme.
M.source_groups = {
  lsp = "Type",
  path = "Directory",
  snippets = "Special",
  buffer = "Comment",
  lazydev = "Function",
  pane = "Constant",
  ripgrep = "Number",
  ghq = "String",
  digraphs = "Identifier",
  git = "WarningMsg",
  dictionary = "Keyword",
  emoji = "Statement",
  nerdfont = "Operator",
  fish = "Macro",
  skkeleton = "Tag",
}

-- カタカナ U+30A1..U+30F6 をひらがなにずらして返す。
-- ー (U+30FC) や記号類、漢字、ASCII はそのまま素通し。
local function kata_to_hira(s)
  return (
    s:gsub("[\xE3][\x82-\x83][\x80-\xBF]", function(ch)
      local cp = vim.fn.char2nr(ch)
      if cp >= 0x30A1 and cp <= 0x30F6 then
        return vim.fn.nr2char(cp - 0x60)
      end
      return ch
    end)
  )
end

-- skkeleton 項目の「読み」を 2 通り返す。
--   display  メニューに出す読み。送りありは SKK の記法で「あた*り」。
--   plain    照合に使う読み。送り仮名まで仮名で繋いだ「あたり」。
-- 送りあり候補の data.kana は辞書の見出し (「あたr」) で、末尾が送り仮名の
-- ローマ字になっている。そのままでは読みとして不自然なうえ送りなしとの違いも
-- 分かりにくいので、見出しから末尾のローマ字を落とした「あた」に、送り仮名
-- 「り」を継ぐ。送り仮名は label (挿入される文字列「当り」) から候補本体
-- (data.word の最初の `;` まで = 「当」) を引いた残り。組み立てに失敗したら
-- 見出しをそのまま使う (両方とも nil を返さない)。
-- 送りなし項目と skkeleton 以外の項目では nil, nil。
--- @return string|nil display
--- @return string|nil plain
local function skk_readings(item)
  local data = item and item.data
  if not (data and data.skkeleton and data.kana and data.kana ~= "") then
    return nil, nil
  end
  if data.henkan_type ~= "okuriari" then
    return data.kana, data.kana
  end
  -- %a は C ロケールの isalpha なので、仮名 (>= 0x80 のバイト) には当たらない。
  local stem = data.kana:match "^(.-)%a+$"
  local candidate = (data.word or ""):match "^[^;]*"
  local okuri
  if candidate ~= "" and item.label and vim.startswith(item.label, candidate) then
    okuri = item.label:sub(#candidate + 1)
  end
  if stem and stem ~= "" and okuri and okuri ~= "" then
    return stem .. "*" .. okuri, stem .. okuri
  end
  return data.kana, data.kana
end

-- 送りあり候補が必ず最後尾に沈むのを、グループ単位の並べ替えで引き上げる。
--
-- skkeleton は [送りなし: 読みに前方一致する見出し全部 × その候補] のうしろに
-- [送りあり: 分割ごと] を連結して返す。送りなしは前方一致なので、「あたり」で
-- 36 件 (見出し 20 個。「あたりやのぶたろう」まで含む) になり、送りあり候補は
-- 37 行目から始まる。メニューは 10 行なので 1 画面目には絶対に出てこない。
-- 辞書の量の問題ではなく (SKK-JISYO.L だけでも 26 件)、連結順の問題。
--
--   1. 確定したことのある送りなし、および読みが入力と完全一致する送りなし
--                                        「あたり」    → 当たり / 辺り …
--   2. 最も深い分割の送りあり            「あた*り」   → 辺り / 当り …
--   3. 残りの送りなし (見出しが伸びたもの)「あたりがね」→ 当り鉦 …
--   4. 浅い分割の送りあり                「あ*たり」   → 会たり … (雑音寄り)
--
-- グループ内の順番 (skkeleton の学習ランク順) はそのまま保ち、sortText だけを
-- 振り直す。skkeleton 項目は filterText が全部同じで score が並ぶため、blink は
-- sort_text で順序を決める。よってこれだけで効く。
--
-- グループ 1 に「確定したことのある候補」(data.rank が付いているもの) を含める。
-- skkeleton は読みに前方一致する見出しを全部返すので、学習した語の見出しは入力
-- より長いことが多い。完全一致だけをグループ 1 にすると、「とうろ」で 5 件の稀語
-- (当路・塘路・凍露…) が上を占め、何度確定しても「登録」(見出し「とうろく」) が
-- その下に居座る。ランクの有無は blink-cmp-skkeleton が skkeleton の getRanks から
-- 運んでくる。
--
-- 入力の読みは送りあり候補の読みから取る (どの分割でも、語幹に送り仮名を繋いだ
-- ものは入力と一致する)。送りあり候補が 1 つも無ければ並べ替えない。
--
-- グループ 2 は「読みを 1 文字だけ残して切った分割」= 語幹が「読みの長さ - 1」の
-- ものに限る。実在する候補のうち最も深いものを 2 に入れると、深い分割が辞書に
-- 当たらなかったときに浅い分割が繰り上がってしまう。「あくせ」では「あく」+「せ」
-- (見出し あくs) が 0 件なので、本来 4 に落ちるはずの「あ」+「くせ」(あk の 15
-- 候補「開くせ」…) が 2 に座り、グループ 3 の「アクセス」を 1 画面目から追い出す。
local function skk_regroup(items)
  local reading, reading_len
  local meta = {}
  for i, item in ipairs(items) do
    local data = item.data
    if data and data.skkeleton then
      local _, plain = skk_readings(item)
      local okuriari = data.henkan_type == "okuriari"
      local stem_len = 0
      if okuriari then
        stem_len = vim.fn.strchars(data.kana:match "^(.-)%a+$" or "")
        -- 読みの組み立てに失敗した項目は plain が見出し (「あk」) のままなので、
        -- 末尾がローマ字のものは読みとして採らない。
        if not reading and plain and not plain:match "%a$" then
          reading = plain
          reading_len = vim.fn.strchars(plain)
        end
      end
      meta[i] = { plain = plain, okuriari = okuriari, stem_len = stem_len, ranked = data.rank ~= nil }
    end
  end
  if not reading then
    return items
  end

  local order = {}
  for i, item in ipairs(items) do
    local m = meta[i]
    local group
    if not m then
      -- このプロバイダは skkeleton 項目しか返さないので実際には通らない。
      group = 1
    elseif m.okuriari then
      group = m.stem_len == reading_len - 1 and 2 or 4
    else
      group = (m.ranked or m.plain == reading) and 1 or 3
    end
    order[#order + 1] = { item = item, group = group, index = i }
  end
  table.sort(order, function(a, b)
    if a.group ~= b.group then
      return a.group < b.group
    end
    return a.index < b.index
  end)

  local out = {}
  for i, entry in ipairs(order) do
    entry.item.sortText = string.format("%010d", i)
    out[i] = entry.item
  end
  return out
end

-- frizbee は UTF-8 を理解しないバイト単位 subsequence matcher なので、入力
-- ひらがなが label のカタカナや漢字と「先頭 1 byte だけ」「2 byte だけ」一致
-- して中途半端に光ってしまう。skkeleton 項目では辞書 key 全体 (item.data.kana,
-- 例 "おねがいします") と label (例 "お願いします") を文字単位で整列させ、各
-- label char が読みのどの範囲を担当するかを決定 → 入力の prefix
-- (item.filterText, 例 "おねがいし") がその範囲を完全に覆っていれば光らせる。
-- 整列のルール:
--   * 各 label char をひらがな化したものが「読みの残り」と一致したら、その
--     位置を端点として確定 (kp = j+1 に進める)。
--   * 一致しない char (漢字、ASCII 等) は pending に積み、次に揃った hira/kata
--     が見つかった時点で「前回の確定位置 .. 今回の j-1」を pending 全体に割り
--     当てる (連続する漢字は同じ範囲を共有する保守的な扱い)。
--   * 末尾に残った pending は読みの末尾まで覆うとみなす。
-- これにより、漢字も「自分が担当する読み区間がユーザ入力に完全に含まれている」
-- 場合だけ光る。逆に半端な入力 ("おね" だけで「願」がまだ "ねが" の "ね" しか
-- 来ていない等) では光らない、保守的な挙動になる。
local function skk_label_match_ranges(item)
  if not (item and item.label and item.filterText and item.filterText ~= "") then
    return {}
  end
  -- 送りあり候補は見出し (「あたr」) ではなく送り仮名まで仮名で繋いだ読み
  -- (「あたり」) で整列する。label の「り」は見出しの "r" とは一致しない。
  local _, full_kana = skk_readings(item)
  if not full_kana or full_kana == "" then
    return {}
  end
  local label_chars = vim.fn.split(item.label, "\\zs")
  local fk_chars = vim.fn.split(kata_to_hira(full_kana), "\\zs")
  local typed_n = vim.fn.strchars(item.filterText)

  local start_pos, end_pos = {}, {}
  local pending = {}
  local kp = 1
  for i, ch in ipairs(label_chars) do
    local norm = kata_to_hira(ch)
    local j
    for m = kp, #fk_chars do
      if fk_chars[m] == norm then
        j = m
        break
      end
    end
    if j then
      for _, ki in ipairs(pending) do
        start_pos[ki] = kp
        end_pos[ki] = j - 1
      end
      pending = {}
      start_pos[i], end_pos[i] = j, j
      kp = j + 1
    else
      table.insert(pending, i)
    end
  end
  for _, ki in ipairs(pending) do
    start_pos[ki] = kp
    end_pos[ki] = #fk_chars
  end

  local ranges, byte_pos = {}, 0
  for i, ch in ipairs(label_chars) do
    -- start > end means this char covers zero kana (e.g. ラベル中の余計な
    -- 記号や読みに含まれない文字)。読みを担当していないのでハイライト対象外。
    if start_pos[i] and end_pos[i] and start_pos[i] <= end_pos[i] and end_pos[i] <= typed_n then
      table.insert(ranges, { byte_pos, byte_pos + #ch })
    end
    byte_pos = byte_pos + #ch
  end
  return ranges
end

-- label.highlight コールバック本体を包む wrapper。skkeleton 項目について
-- だけ ctx.label_matched_indices を一時的に空にして inner を呼ぶことで、
-- inner (および colorful-menu) が出してくる frizbee 由来の誤
-- BlinkCmpLabelMatch を抑止し、その後で正しい文字単位の range を追加する。
-- skkeleton 以外の項目では完全な no-op として振る舞う。
function M.with_skk_label_match(ctx, inner)
  local is_skk = ctx.item and ctx.item.data and ctx.item.data.skkeleton
  local saved
  if is_skk then
    saved = ctx.label_matched_indices
    ctx.label_matched_indices = {}
  end
  local highlights = inner(ctx)
  if is_skk then
    ctx.label_matched_indices = saved
    for _, r in ipairs(skk_label_match_ranges(ctx.item)) do
      table.insert(highlights, { r[1], r[2], group = "BlinkCmpLabelMatch" })
    end
  end
  return highlights
end

-- skkeleton 由来の候補は skkeleton が決めた順 (= sortText。順位学習と
-- skk_regroup のグループ分けを写したもの) で並べたいので、Lua コンパレータを
-- 'score' より前に置く。
--
-- score に委ねると学習が反映されない。blink の score には frecency のボーナスが
-- 乗っており、これは accept のたびに fuzzy.access() が記録する「その候補を確定
-- した回数」だからである。同じ読みの候補は filterText が同一で素点が並ぶため、
-- 差が付くのはこのボーナスだけになり、「いつも <CR> で確定している語」が先頭に
-- 固定されて、skkeleton 側でいくら学習しても順番が動かない。
--
-- 以前は data.rank を見ていたが、プラグインが getCompleteItems へ切り替えた
-- ときに rank を渡さなくなり、このコンパレータは常に nil を返す (= 何もしない)
-- 状態になっていた。skkeleton 以外の項目では今までどおり nil を返す。
local function skk_order_sort(a, b)
  if not (a.data and a.data.skkeleton and b.data and b.data.skkeleton) then
    return nil
  end
  if a.sortText == nil or b.sortText == nil or a.sortText == b.sortText then
    return nil
  end
  return a.sortText < b.sortText
end

-- 静的に使い回す (毎回テーブルを作らない)。blink は sorts_list を読み取り専用
-- に扱うので共有しても安全。
local SORTS_WITH_SKK = { skk_order_sort, "score", "sort_text" }
local SORTS_DEFAULT = { "score", "sort_text" }

-- blink.cmp の fuzzy.sorts に「関数」として渡す動的ソート定義。blink は補完の
-- たびにこれを呼ぶ (fuzzy/init.lua: type(config.fuzzy.sorts) == 'function')。
-- skkeleton 補完中だけ Lua コンパレータ入りのリストを返し、それ以外は文字列
-- だけのリストを返す。後者では blink の Rust 側 sort 最適化 (sort_in_rust) が
-- 効く。sorts に Lua 関数が 1 つでも混ざると毎回 Lua の table.sort に落ちるた
-- め、skkeleton 用関数を常時置いておく書き方では OFF 時も最適化が効かなかった。
function M.fuzzy_sorts()
  local ok, skk = pcall(require, "blink-cmp-skkeleton")
  if ok and skk.is_enabled() then
    return SORTS_WITH_SKK
  end
  return SORTS_DEFAULT
end

-- Returns blink.cmp menu draw components (kind_icon override + source_name)
-- that color each candidate by its source. The caller can merge with its own
-- `label` component (e.g. for colorful-menu integration).
function M.menu_components()
  return {
    kind_icon = {
      ellipsis = false,
      text = function(ctx)
        local icon = M.source_icons[ctx.source_id]
        if icon then
          local data = ctx.item.data
          if data and data.skkeleton and data.henkan_type == "okuriari" then
            icon = SKK_OKURIARI_ICON
          end
          return icon .. ctx.icon_gap
        end
        return ctx.kind_icon .. ctx.icon_gap
      end,
      highlight = function(ctx)
        local hl = M.source_groups[ctx.source_id]
        if hl then
          return { { group = hl, priority = 20000 } }
        end
        return { { group = ctx.kind_hl, priority = 20000 } }
      end,
    },
    source_name = {
      width = { max = 12 },
      -- skkeleton 項目では source 名 ("skkeleton") を出さない。左端アイコンが既に
      -- "J" で skkeleton を示しており冗長なうえ、これを空にすることで label の
      -- fill による余白が右端 (見えない位置) に流れ、メニューが横に間延びしない。
      text = function(ctx)
        if ctx.item.data and ctx.item.data.skkeleton then
          return ""
        end
        return ctx.source_name
      end,
      highlight = function(ctx)
        return M.source_groups[ctx.source_id] or "BlinkCmpSource"
      end,
    },
  }
end

-- skkeleton 補完メニューで読み (見出し) を候補 label のうしろに出すときの
-- レイアウト設定。表示桁 (全角=2, 半角=1) で数える。
--  * label が SKK_LABEL_MIN_W 未満なら空白で右詰めパディングしてから区切りを
--    置くので、短い候補どうしでは読みの開始位置が揃う (printf "%-Ns  " 相当)。
--  * label が SKK_LABEL_MIN_W 以上なら区切りだけ空けて読みを続ける。
--  * 読みが SKK_READING_MAX_W を超えたら … で打ち切る。
-- 区切りには記号を置かず、読みを SKK_READING_HL で色分けして候補と区別する
-- (全角スペースはフォントによって幅がずれるため半角スペース 2 個を使う)。
local SKK_LABEL_MIN_W = 10 -- 読みの開始位置を揃える最小フィールド幅 (表示桁)
local SKK_READING_MAX_W = 12 -- 読みの最大表示幅。超過分は … で省略
local SKK_SEP = "  " -- 候補と読みの間隔 (半角スペース 2 個)
-- 読みのハイライトグループ。候補 (BlinkCmpLabel) と色で区別するのが目的。
-- Comment は colorscheme が必ず定義する薄い二次色で、区切り記号を置かずとも
-- 読みが視覚的に分離する。好みで "NonText" や独自グループに変えてよい
-- (BlinkCmpLabelDescription は未定義だと無色になり区別が付かない)。
local SKK_READING_HL = "Comment"

-- Truncate `s` to at most `max_w` display columns, appending "…" if cut.
local function skk_truncate(s, max_w)
  if vim.api.nvim_strwidth(s) <= max_w then
    return s
  end
  local ellipsis = "…"
  local budget = max_w - vim.api.nvim_strwidth(ellipsis)
  local acc, w = {}, 0
  for _, ch in ipairs(vim.fn.split(s, "\\zs")) do
    local cw = vim.api.nvim_strwidth(ch)
    if w + cw > budget then
      break
    end
    acc[#acc + 1] = ch
    w = w + cw
  end
  return table.concat(acc) .. ellipsis
end

-- Layout the reading appended to a skk `label`: returns the appended suffix
-- (padding + separator + truncated reading), the byte offset where the reading
-- starts (relative to the label), and the reading string itself. Deterministic
-- from (label, kana) so text() and highlight() agree without recomputing the
-- (potentially expensive) colorful-menu label text a second time.
local function skk_reading_layout(label, kana)
  local pad = math.max(0, SKK_LABEL_MIN_W - vim.api.nvim_strwidth(label))
  local reading = skk_truncate(kana, SKK_READING_MAX_W)
  local lead = string.rep(" ", pad) .. SKK_SEP
  return lead .. reading, #label + #lead, reading
end

-- Wrap a label component so skkeleton items show their reading (見出し) after the
-- label (see skk_reading_layout for the spacing rules). Putting the reading in
-- the label text (rather than a separate right-aligned column) keeps the menu
-- compact; the filling label pads to the far right (invisible) after the reading.
-- Same 表層形 under different readings (安 → やす / やすし / やすまる) becomes
-- distinguishable. Non-skkeleton items pass through untouched (LSP unaffected).
function M.with_skk_reading(component)
  -- 送りありは「あた*り」、送りなしは見出しそのまま (skk_readings 参照)。
  local function kana_of(ctx)
    return (skk_readings(ctx.item))
  end
  return {
    text = function(ctx)
      local base = component.text(ctx) or ""
      local kana = kana_of(ctx)
      if not kana then
        return base
      end
      -- base (colorful text) equals ctx.label for skk items (no label_detail),
      -- so width/offset computed from ctx.label match the displayed base.
      local suffix = skk_reading_layout(ctx.label or base, kana)
      return base .. suffix
    end,
    highlight = function(ctx)
      local highlights = component.highlight(ctx) or {}
      local kana = kana_of(ctx)
      if kana then
        local _, start, reading = skk_reading_layout(ctx.label or "", kana)
        table.insert(highlights, { start, start + #reading, group = SKK_READING_HL })
      end
      return highlights
    end,
  }
end

-- Returns the common blink.cmp provider configs. Callers extend with their
-- own config-specific providers (e.g. lazydev / lsp / fish / nerdfont / path
-- with custom opts) via vim.tbl_extend.
function M.providers()
  return {
    -- Boost LSP above source-flooding providers (ghq returns ~800 items,
    -- buffer can return ~400, wezterm 100+, etc.). Without this, an empty-
    -- prefix LSP query like `vim.|` ranks LSP items in the noise and the
    -- menu's visible top-N is dominated by other sources. lazydev sits at
    -- score_offset = 100 so it stays above LSP for require()-style paths.
    lsp = { score_offset = 50 },
    buffer = {
      opts = {
        get_bufnrs = function()
          return vim.iter(vim.api.nvim_list_bufs()):filter(vim.api.nvim_buf_is_loaded):totable()
        end,
      },
    },
    pane = { name = "pane", module = "blink-cmp-pane", min_keyword_length = 2, async = true },
    ghq = { name = "ghq", module = "blink-cmp-ghq", async = true },
    ripgrep = {
      name = "Ripgrep",
      module = "blink-ripgrep",
      async = true,
      -- CJK には単語境界が無く、rg が組み立てる `<prefix>[\w_-]+` の \w は Rust
      -- 正規表現で既定 Unicode 対応なので仮名・漢字・助詞まで 1 語として飲み込む。
      -- 結果「Confluenceページから作業履歴を振り返り」のように行末まで拾われ、
      -- 純粋な "Confluence" が候補に出ない。ここで各候補を先頭の ASCII 単語
      -- ([A-Za-z0-9_-] の連なり) だけに切り詰め、同じ語に畳む。日本語を rg で
      -- 補完する道は塞がるが、元々フレーズごと拾って壊れており日本語入力は
      -- skkeleton が担うので実害は無い。
      --
      -- これは source プロバイダ層 (blink 内部の `n`) の変換で、fuzzy に入る前に
      -- 候補リストを書き換えるだけ。fuzzy.sorts の Rust sort 最適化 (M.fuzzy_sorts,
      -- sort_in_rust) は fuzzy.sorts が全部文字列かだけで決まり transform_items は
      -- 参照されないので、この最適化はそのまま効く。
      transform_items = function(_, items)
        local seen, out = {}, {}
        for _, item in ipairs(items) do
          local word = (item.label or ""):match "^[%w_-]+"
          if word then
            word = (word:gsub("%-+$", "")) -- 末尾に残る余分な - を落とす
          end
          if word and word ~= "" then
            if not seen[word] then
              seen[word] = true
              item.label = word
              item.insertText = word
              item.filterText = word
              out[#out + 1] = item
            end
          else
            out[#out + 1] = item
          end
        end
        return out
      end,
      opts = {
        prefix_min_len = 4,
        backend = {
          use = "ripgrep",
          ripgrep = {
            context_size = 5,
            max_filesize = "1M",
            search_casing = "--ignore-case",
          },
        },
      },
    },
    emoji = {
      name = "Emoji",
      module = "blink-emoji",
      score_offset = 15,
      opts = {
        insert = true,
        trigger = function()
          return { ":" }
        end,
      },
    },
    dictionary = {
      name = "Dict",
      module = "blink-cmp-dictionary",
      min_keyword_length = 4,
      async = true,
      opts = { dictionary_files = { "/usr/share/dict/words" } },
    },
    digraphs = {
      name = "Digraphs",
      module = "blink-cmp-digraphs",
      -- Allow invocation when no keyword chars are present (e.g. typing
      -- "->" or "+-") so trigger characters alone fire the source.
      min_keyword_length = 0,
      -- Boost only when the user has typed both characters of a digraph
      -- (e.g. "Ye", "oe"). On a single-char prefix (e.g. just ":"), leave
      -- the boost off so we don't drown out emoji on the shared `:`
      -- trigger.
      transform_items = function(ctx, items)
        local col = ctx.cursor[2]
        local prefix = ctx.line:sub(math.max(1, col - 1), col)
        local boost = #prefix >= 2 and 50 or 0
        for _, item in ipairs(items) do
          item.score_offset = (item.score_offset or 0) + boost
        end
        return items
      end,
    },
    git = {
      name = "Git",
      module = "blink-cmp-git",
      async = true,
      opts = {
        git_centers = {
          github = {
            issue = M.github_feature_override "issue",
            pull_request = M.github_feature_override "pull_request",
            mention = M.github_feature_override "mention",
          },
        },
        -- Override the commit feature so it:
        -- 1. Uses `;` instead of the default `:` trigger. The default
        --    collides with emoji / nerdfont / digraphs on `:` and the
        --    commit hashes get drowned out. `;` is rare in real code and
        --    dedicates the trigger to commit completion.
        -- 2. Also activates in GHE repos (default only checks github.com).
        -- 3. Limits `git log` to the most recent 100 commits so pre-cache
        --    stays fast in large repos.
        commit = {
          triggers = { ";" },
          enable = function()
            local default = require("blink-cmp-git.default.commit").enable
            return default() or M.matched_ghe_host() ~= nil
          end,
          get_command_args = function(command, token)
            local default = require("blink-cmp-git.default.commit").get_command_args
            local args = default(command, token)
            if command == "git" then
              table.insert(args, "-100")
            end
            return args
          end,
        },
      },
    },
    skkeleton = {
      name = "skkeleton",
      module = "blink-cmp-skkeleton",
      -- 同じ読み・同じ表層形の候補が複数辞書から違う文字列で返ることがある
      -- (例: user 辞書の "安" と yaskkserv2 の "安;姓")。skkeleton は完全一致
      -- でしか重複排除しないので両方残り、注釈 (;…) を落とした表示ラベルが同じ
      -- になって「安 やす」が 2 行出る。ここで (読み + 表示ラベル) で畳む。
      -- items は plugin 側で rank 降順に並んでいるため最初の 1 件 (= 最上位) を
      -- 残し、注釈由来の documentation は残す方に移植する。
      transform_items = function(_, items)
        local seen = {}
        local out = {}
        for _, item in ipairs(items) do
          local data = item.data
          if data and data.skkeleton then
            local key = (data.kana or "") .. "\0" .. (item.label or "")
            local prev = seen[key]
            if prev then
              if not prev.documentation and item.documentation then
                prev.documentation = item.documentation
              end
            else
              seen[key] = item
              out[#out + 1] = item
            end
          else
            out[#out + 1] = item
          end
        end
        -- 畳んだあとに、送りあり候補を 1 画面目の近くへ引き上げる (skk_regroup)。
        return skk_regroup(out)
      end,
    },
  }
end

-- Register `:BlinkProf` and `:BlinkProfPath` user commands. The profiler
-- monkey-patches each blink.cmp source provider's `get_completions` to record
-- per-source latency and item counts. Call once during config load; the
-- patching is lazy and only kicks in when the user runs `:BlinkProf`.
function M.setup_profiler()
  local prof = { on = false, log = {}, wrapped = {} }

  local function wrap_module(id, mod)
    if prof.wrapped[id] or type(mod.get_completions) ~= "function" then
      return
    end
    prof.wrapped[id] = true
    local orig = mod.get_completions
    mod.get_completions = function(self, ctx, cb)
      if not prof.on then
        return orig(self, ctx, cb)
      end
      local t0 = vim.uv.hrtime()
      local kw = ctx.line:sub(ctx.bounds.start_col, ctx.cursor[2])
      return orig(self, ctx, function(resp)
        local dt = (vim.uv.hrtime() - t0) / 1e6
        table.insert(prof.log, {
          id = id,
          ms = dt,
          kw = kw,
          n = (resp and resp.items) and #resp.items or 0,
        })
        cb(resp)
      end)
    end
  end

  local function arm()
    local lib = require "blink.cmp.sources.lib"
    for id, prov in pairs(lib.providers) do
      if prov and prov.module then
        wrap_module(id, prov.module)
      end
    end
    if not lib._blink_prof_patched then
      lib._blink_prof_patched = true
      local orig = lib.get_provider_by_id
      lib.get_provider_by_id = function(pid)
        local prov = orig(pid)
        if prov and prov.module then
          wrap_module(pid, prov.module)
        end
        return prov
      end
    end
  end

  vim.api.nvim_create_user_command("BlinkProfPath", function(opts)
    local dir = vim.fn.expand(opts.args ~= "" and opts.args or "%:p:h")
    local t0 = vim.uv.hrtime()
    vim.uv.fs_scandir(dir, function(err, req)
      local t_open = (vim.uv.hrtime() - t0) / 1e6
      if err or not req then
        vim.schedule(function()
          vim.notify("scandir error: " .. tostring(err))
        end)
        return
      end
      local count = 0
      while vim.uv.fs_scandir_next(req) do
        count = count + 1
      end
      local t_walk = (vim.uv.hrtime() - t0) / 1e6
      local t_sched = vim.uv.hrtime()
      vim.schedule(function()
        local t_lat = (vim.uv.hrtime() - t_sched) / 1e6
        vim.notify(
          string.format(
            "%s\n  scandir open : %.2fms\n  walk %d entries: %.2fms\n  schedule lat : %.2fms",
            dir,
            t_open,
            count,
            t_walk - t_open,
            t_lat
          )
        )
      end)
    end)
  end, { nargs = "?", complete = "dir" })

  vim.api.nvim_create_user_command("BlinkProf", function(opts)
    local arg = opts.args
    if arg == "off" then
      prof.on = false
      vim.notify("BlinkProf OFF (" .. #prof.log .. " entries logged)")
    elseif arg == "clear" then
      prof.log = {}
      vim.notify "BlinkProf log cleared"
    elseif arg == "dump" then
      local sums = {}
      for _, e in ipairs(prof.log) do
        local s = sums[e.id] or { n = 0, total = 0, max = 0, items = 0 }
        s.n = s.n + 1
        s.total = s.total + e.ms
        s.max = math.max(s.max, e.ms)
        s.items = s.items + e.n
        sums[e.id] = s
      end
      local rows = {}
      for id, s in pairs(sums) do
        table.insert(rows, { id = id, s = s })
      end
      table.sort(rows, function(a, b)
        return a.s.total > b.s.total
      end)
      local lines = {
        string.format("%-15s %5s  %9s  %7s  %8s  %6s", "source", "calls", "total(ms)", "avg(ms)", "max(ms)", "items"),
      }
      for _, r in ipairs(rows) do
        table.insert(
          lines,
          string.format(
            "%-15s %5d  %9.1f  %7.2f  %8.2f  %6d",
            r.id,
            r.s.n,
            r.s.total,
            r.s.total / r.s.n,
            r.s.max,
            r.s.items
          )
        )
      end
      table.insert(lines, "")
      table.insert(lines, "slowest single calls:")
      local sorted = vim.deepcopy(prof.log)
      table.sort(sorted, function(a, b)
        return a.ms > b.ms
      end)
      for i = 1, math.min(10, #sorted) do
        local e = sorted[i]
        table.insert(lines, string.format("  %7.2fms  %-12s  items=%d  kw=%q", e.ms, e.id, e.n, e.kw))
      end
      vim.notify(table.concat(lines, "\n"))
    else
      arm()
      prof.on = true
      prof.log = {}
      vim.notify "BlinkProf ON"
    end
  end, {
    nargs = "?",
    complete = function()
      return { "off", "clear", "dump" }
    end,
  })
end

return M
