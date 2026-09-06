--- statuscol.nvim の行番号セグメント。
---
--- line-justice.nvim が描いていた 4 つの列 — マーク・絶対行番号・相対行番号・
--- 折り返しインジケータ — をそのまま再現する。距離によるフェードだけを
--- bokeh.nvim に任せ、ここは配置と静的な色を持つ。
---
---   [mark 1][gap 1][absolute col_w][sep 1][relative 3][trailing 1]
---
--- 相対行番号の色は BokehFadeAbove* / BokehFadeBelow* が付ける。`:Bokeh off`
--- でフェードを切ると bokeh.hl() が空文字列を返すので、下の静的な色に落ちる。
local M = {}

--- 折り返し行・仮想行に出す文字 (line-justice の indicator = "Bar" 相当)。
local INDICATOR = "│"

--- 相対行番号の桁数。これを超える距離は右 3 桁だけ出す。
local REL_WIDTH = 3

--- ガター全体の幅は「絶対行番号の幅 + 6」。内訳は mark 1 + gap 1 + sep 1 +
--- relative 3 + trailing 1。
local EXTRA_WIDTH = 6

--- 色は line-justice の Horizon テーマ (カーソルより上が青い空、下が緑の大地) を
--- 引き継ぐ。個々のカラースキームには追従しない。
---
--- Horizon は暗い背景専用で、明るい背景では相対行番号が 2.2:1、カーソル行の
--- #ff966c に至っては 1.7:1 しか出ず、ほとんど読めなかった。light は色相と彩度を
--- 保ったまま明度だけを解き直して、dark と同じコントラスト比に揃えてある。
--- 括弧内は tokyonight-storm (#24283b) / tokyonight-day (#e1e2e7) での比。
---
--- カーソル行とマークだけは dark の比 (6.8:1 / 11.7:1) をそのまま狙うと焦げ茶と
--- 黒に落ちるので、5.5:1 / 7.0:1 で止めている。
local COLORS = {
  dark = {
    GutterCursor = { fg = "#ff966c", bold = true }, -- 6.8:1
    GutterAbsoluteAbove = { fg = "#565f89" }, -- 2.4:1
    GutterAbsoluteBelow = { fg = "#41664f" }, -- 2.2:1
    GutterRelativeAbove = { fg = "#7b9ac7" }, -- 5.1:1
    GutterRelativeBelow = { fg = "#6aa781" }, -- 5.2:1
    GutterWrapped = { fg = "#565f89", italic = true }, -- 2.4:1
    GutterMark = { fg = "#8cf8f7" }, -- 11.7:1
  },
  light = {
    GutterCursor = { fg = "#a32e00", bold = true }, -- 5.5:1
    GutterAbsoluteAbove = { fg = "#8b92b6" }, -- 2.4:1
    GutterAbsoluteBelow = { fg = "#6ea382" }, -- 2.2:1
    GutterRelativeAbove = { fg = "#3d5e8f" }, -- 5.1:1
    GutterRelativeBelow = { fg = "#3b654b" }, -- 5.2:1
    GutterWrapped = { fg = "#8b92b6", italic = true }, -- 2.4:1
    GutterMark = { fg = "#055251" }, -- 7.0:1
  },
}

---3 桁ごとにカンマを打つ。
---@param n integer
---@return string
local function commify(n)
  return (tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

--- `vim.bo[buf]` は添字を引くたびにプロキシテーブルを作り直すので 1 回 280ns
--- 掛かる。画面の行ごとに評価される場所には重すぎるが、プロキシ自体は常に今の
--- 値を読むので、使い回しても正しさは変わらない。
local bo_cache = setmetatable({}, {
  __index = function(cache, buf)
    local proxy = vim.bo[buf]
    rawset(cache, buf, proxy)
    return proxy
  end,
})

--- マークは 1 回の再描画のあいだだけキャッシュする。getmarklist() は行ごとに
--- 呼ぶには重く、かといって持ち越すと `ma` を打った直後に古い表示が残る。
local mark_cache = {}
local mark_scheduled = false

---バッファ内の行番号 → マーク文字。
---@param buf integer
---@return table<integer, string>
local function marks_for(buf)
  local cached = mark_cache[buf]
  if cached then
    return cached
  end

  local marks = {}
  -- バッファローカルのマーク (a-z)
  for _, mark in ipairs(vim.fn.getmarklist(buf)) do
    local char, lnum = mark.mark:sub(2, 2), mark.pos[2]
    if lnum > 0 and char:match "%l" then
      marks[lnum] = marks[lnum] or char
    end
  end
  -- グローバルマーク (A-Z) のうち、このバッファを指しているもの
  for _, mark in ipairs(vim.fn.getmarklist()) do
    local char, lnum = mark.mark:sub(2, 2), mark.pos[2]
    if lnum > 0 and char:match "%u" and mark.pos[1] == buf then
      marks[lnum] = marks[lnum] or char
    end
  end

  mark_cache[buf] = marks
  if not mark_scheduled then
    mark_scheduled = true
    vim.schedule(function()
      mark_cache, mark_scheduled = {}, false
    end)
  end
  return marks
end

---`str` を `width` 桁の中央に置く。
---@param str string
---@param width integer
---@return string
local function centre(str, width)
  local pad = width - vim.api.nvim_strwidth(str)
  if pad <= 0 then
    return str
  end
  local left = math.floor(pad / 2)
  return (" "):rep(left) .. str .. (" "):rep(pad - left)
end

---bokeh の起点となるものも含め、ガターのハイライトグループを定義する。
---
--- `:colorscheme` は全ハイライトを消すので、ColorScheme のたびに呼び直す必要が
--- ある。呼び直したら bokeh.setup(M.bokeh_opts()) で段も作り直させること。
function M.highlights()
  for name, attrs in pairs(COLORS[vim.o.background] or COLORS.dark) do
    vim.api.nvim_set_hl(0, name, attrs)
  end
end

---相対行番号のフェードに使う bokeh の設定。
---
--- 明るい背景は 1 段あたりの効きが強く、同じ amount では沈みすぎる。背景ごとに
--- 変えて、どちらでも起点 5.0:1 から最遠 2.0:1 前後へ落ちるように揃えている。
---
--- dark での段ごとのコントラスト比:
---   5.0 → 4.8 → 4.5 → 4.1 → 3.6 → 3.1 → 2.5 → 2.0
--- 静的な絶対行番号が 2.4:1 なので、最遠の 1〜2 段では絶対行番号のほうが僅かに
--- 濃くなる。
---
--- amount を 1.0 まで振らないのは、そこまで行くと段 8 が上下とも背景色に着地して
--- 青と緑の塗り分けが「まさにフェードが効いてほしい遠く」で消えてしまうため。
---@return table
function M.bokeh_opts()
  return {
    bands = 8,
    distance = 24,
    curve = "ease_in",
    amount = vim.o.background == "dark" and 0.6 or 0.5,
    from = { above = "GutterRelativeAbove", below = "GutterRelativeBelow" },
  }
end

---statuscol.nvim の text セグメント。
---@param args table  statuscol がセグメントに渡す引数
---@return string
function M.segment(args)
  if bo_cache[args.buf].buftype == "nofile" then
    return ""
  end

  -- 'number' も 'relativenumber' も無いウィンドウでは、行番号列そのものを畳む。
  -- ヘルプは Neovim 自身が `nonu nornu` で開き、quickfix とターミナルは
  -- after/ftplugin/qf.lua と core/options/term.lua がそうしている。そこで
  -- ここだけ番号を描き続けてしまうのを防ぐ。statuscol.nvim の builtin.lnumfunc
  -- も同じ判定をしている。折り返し行のインジケータより手前で返すこと。
  if not (args.nu or args.rnu) then
    return ""
  end

  local width = #commify(vim.api.nvim_buf_line_count(args.buf))

  -- 折り返し行・仮想行にはインジケータだけを、ガター全体の中央に置く。
  if args.virtnum ~= 0 then
    return "%#GutterWrapped#" .. centre(INDICATOR, width + EXTRA_WIDTH)
  end

  local mark = marks_for(args.buf)[args.lnum]
  local mark_col = mark and ("%#GutterMark#" .. mark) or " "

  local on_cursor = args.relnum == 0
  local below = not on_cursor and args.lnum > vim.api.nvim_win_get_cursor(args.win)[1]

  local abs_hl
  if on_cursor then
    abs_hl = "%#GutterCursor#"
  else
    abs_hl = below and "%#GutterAbsoluteBelow#" or "%#GutterAbsoluteAbove#"
  end

  -- 距離フェードは bokeh に任せる。カーソル行と `:Bokeh off` のときは空が返る
  -- ので、そのまま静的な色へ落ちる。
  local rel_hl = require("bokeh").hl(args)
  if rel_hl == "" then
    if on_cursor then
      rel_hl = "%#GutterCursor#"
    else
      rel_hl = below and "%#GutterRelativeBelow#" or "%#GutterRelativeAbove#"
    end
  end

  local abs = commify(args.lnum)
  abs = (" "):rep(math.max(0, width - #abs)) .. abs

  -- カーソル行の相対列は空にする ("0" は出さない)。
  local rel = on_cursor and "" or commify(args.relnum)
  if #rel > REL_WIDTH then
    rel = rel:sub(-REL_WIDTH)
  end
  rel = " " .. (" "):rep(math.max(0, REL_WIDTH - #rel)) .. rel

  return mark_col .. " " .. abs_hl .. abs .. rel_hl .. rel .. " "
end

return M
