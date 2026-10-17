-- skkeleton_indicator.nvim の色。主設定 (lua/lazies/minimal.lua) と
-- nvim-dev/skkeleton の両方から使う。nvim-dev 側は blink_shared と同じく
-- package.path にこのディレクトリを足して require する。
--
-- macSKK の「入力モードの色」と揃えるため、配色テーマに依らず ddskk の
-- カーソル色 (skk-vars.el の skk-cursor-*-color、明るい背景用) を背景に使う。
-- 色は X11 の色名を 16 進に直したもの。全角英数の gold だけは白抜きが
-- 読めないので文字を黒にする。abbrev は macSKK に色の設定が無いので
-- ddskk の royalblue をそのまま使う。
--
-- :hi clear で消えるので、ColorScheme のたびに M.apply() を呼ぶこと。

local M = {}

function M.apply()
  local function hl(name, fg, bg)
    vim.api.nvim_set_hl(0, "SkkeletonIndicator" .. name, { fg = fg, bg = bg, bold = true })
  end
  hl("Eiji", "#FFFFFF", "#8B8B83") -- ivory4
  hl("Hira", "#FFFFFF", "#8B3E2F") -- coral4
  hl("Kata", "#FFFFFF", "#228B22") -- forestgreen
  hl("Hankata", "#FFFFFF", "#8A2BE2") -- blueviolet
  hl("Zenkaku", "#000000", "#FFD700") -- gold
  hl("Abbrev", "#FFFFFF", "#4169E1") -- royalblue
end

return M
