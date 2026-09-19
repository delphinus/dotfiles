-- 補完の送りありで語幹とみなす部分の下限 (skkeleton の
-- completionOkuriMinStemLength)。fork のブランチ
-- feat/completion-okuri-min-stem-length にしか無いので、主設定と nvim-dev で
-- 同じ判定を共有する。
--
-- 下限が無いと読みを全ての位置で切って送りあり変換として引くため、語幹 1 文字の
-- 見出しに当たる。「あくせ」では「あ」+「くせ」で見出し「あk」を引き、その候補が
-- 「開くせ」「空くせ」… として補完一覧を埋め、送りなしの「アクセス」を一覧の外へ
-- 押し出す。
local M = {}

-- 試用中の下限。きつすぎる (語幹 1 文字の候補も欲しい) なら 0、緩すぎるなら 3。
-- 送り仮名 1 文字の組 (「あ」+「く」→「開く」) は語幹が短くても常に残る。
M.min_stem_length = 2

-- そのチェックアウトがこのオプションを持っているか。持たない skkeleton に渡すと
-- setConfig が unknown option で throw し、skkeleton#config() が丸ごと失敗して
-- 日本語入力の設定がすべて飛ぶ。dotfiles を pull しただけでまだ :Lazy sync して
-- いない端末がこれに当たるので、渡す前にソースを見て確かめる。
---@param dir string skkeleton のチェックアウト
---@return boolean
function M.supported(dir)
  local f = io.open(dir .. "/denops/skkeleton/config.ts")
  if not f then
    return false
  end
  local src = f:read "a"
  f:close()
  return src:find("completionOkuriMinStemLength", 1, true) ~= nil
end

return M
