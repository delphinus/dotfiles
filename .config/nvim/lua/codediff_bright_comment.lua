-- codediff の差分行に重なるコメントだけを明るくする。
--
-- diff の中ではコメント (特に /// のドキュメントコメント) が diff の背景色に
-- 埋もれて読みにくい。codediff が差分行に張るハイライト (CodeDiffLineInsert /
-- Delete / Move) に重なるコメントだけを、明るい前景色の extmark で塗り直して
-- コントラストを上げる。差分行でないコンテキスト行のコメントや通常の編集
-- バッファには一切影響しない。
--
-- treesitter の @comment / @comment.* キャプチャを使うので言語非依存 (parser が
-- あり、コメントが @comment 系で捕捉される言語すべてで効く)。Python の docstring
-- のように文字列扱い (@string.documentation) のものは対象外。
--
-- サンドボックス (nvim-dev/codediff) とメイン config の両方から setup() を呼ぶ。

local M = {}

-- 塗り直し用の extmark を置く自前 namespace
local ns = vim.api.nvim_create_namespace "codediff-bright-comment"

-- 差分行を示す行レベルハイライト。char レベル (文字単位) は行が既に対象なので見ない。
local line_groups = {
  CodeDiffLineInsert = true,
  CodeDiffLineDelete = true,
  CodeDiffLineMove = true,
}

-- Comment の前景色を Normal の前景色へ何割寄せるか (0 = 変えない, 1 = Normal fg)
local lift = 0.5

-- codediff が差分行ハイライトを置く namespace (遅延ロードなので初回に解決する)
local cd_ns
local function get_cd_ns()
  if cd_ns == nil then
    local ok, m = pcall(require, "codediff.ui.highlights")
    cd_ns = (ok and m.ns_highlight) or false
  end
  return cd_ns or nil
end

local function mix(from, to, t)
  local function chan(shift)
    local a = math.floor(from / shift) % 256
    local b = math.floor(to / shift) % 256
    return math.min(255, math.max(0, math.floor(a + (b - a) * t + 0.5)))
  end
  return chan(65536) * 65536 + chan(256) * 256 + chan(1)
end

local function define_hl()
  local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  -- italic 等の属性は元の Comment のものを引き継ぎ、fg だけ明るくする。bg は
  -- 持たせない (diff の背景色をそのまま透かすため)。
  local hl = vim.tbl_extend("force", comment, {
    fg = mix(comment.fg or 0x808080, normal.fg or 0xffffff, lift),
    bg = nil,
  })
  vim.api.nvim_set_hl(0, "CodeDiffBrightComment", hl)
end

-- buf のコメント範囲のうち、差分行に重なる部分だけを塗り直す。
local function repaint(buf)
  local nsid = get_cd_ns()
  if not nsid or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  -- 差分行 (0-based) の集合を作る
  local rows, nline = {}, 0
  for _, mk in ipairs(vim.api.nvim_buf_get_extmarks(buf, nsid, 0, -1, { details = true })) do
    local d = mk[4]
    if d and d.hl_group and line_groups[d.hl_group] then
      nline = nline + 1
      local to = (d.end_row or (mk[2] + 1)) - 1
      for row = mk[2], to do
        rows[row] = true
      end
    end
  end

  -- 差分ハイライトも内容も変わっていなければ再計算しない
  local sig = tostring(vim.b[buf].changedtick) .. "#" .. nline
  if vim.b[buf].codediff_bright_sig == sig then
    return
  end
  vim.b[buf].codediff_bright_sig = sig

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if nline == 0 then
    return
  end

  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then
    return
  end
  local trees = parser:parse()
  local query = vim.treesitter.query.get(parser:lang(), "highlights")
  if not trees or not query then
    return
  end

  -- `///` は @comment と @comment.documentation の両方で捕捉されるため、
  -- 同一範囲への二重塗りを避ける。
  local seen = {}
  for _, tree in ipairs(trees) do
    for id, node in query:iter_captures(tree:root(), buf, 0, -1) do
      local name = query.captures[id]
      if name == "comment" or name:sub(1, 8) == "comment." then
        local sr, sc, er, ec = node:range()
        for row = sr, er do
          -- 末尾行に内容が無い (次行頭で終わる) 場合は塗らない
          local blank_tail = row == er and ec == 0 and er > sr
          local cs = row == sr and sc or 0
          local key = row .. ":" .. cs
          if rows[row] and not blank_tail and not seen[key] then
            seen[key] = true
            local mark = {
              hl_group = "CodeDiffBrightComment",
              priority = 1000, -- treesitter (100) と char diff (200) の上に fg を載せる
            }
            if row == er then
              mark.end_row, mark.end_col = row, ec
            else
              mark.end_row, mark.end_col, mark.hl_eol = row + 1, 0, true
            end
            pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, cs, mark)
          end
        end
      end
    end
  end
end

--- @param opts? { lift?: number } lift: Comment を Normal fg へ寄せる割合 (既定 0.5)
function M.setup(opts)
  if opts and opts.lift then
    lift = opts.lift
  end

  define_hl()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("codediff-bright-comment", { clear = true }),
    callback = define_hl,
  })

  -- codediff は差分行ハイライトをウィンドウ生成のかなり後 (差分計算 → 最初の
  -- hunk へジャンプする頃) に置くため、open 直後に発火する CursorMoved まで
  -- 含めて拾う。差分の張り直し (ファイル切替・編集) にも追従する。実際の再計算は
  -- changedtick + 差分行数のシグネチャで間引く。
  vim.api.nvim_create_autocmd(
    { "BufWinEnter", "WinEnter", "TabEnter", "CursorMoved", "CursorHold", "WinScrolled", "TextChanged" },
    {
      group = vim.api.nvim_create_augroup("codediff-bright-comment-apply", { clear = true }),
      callback = function()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_is_valid(win) and vim.w[win].codediff_restore then
            repaint(vim.api.nvim_win_get_buf(win))
          end
        end
      end,
    }
  )
end

return M
