-- 補完で送り仮名とみなす長さの上限 (skkeleton の completionOkuriMaxLength)。
-- fork のブランチ feat/completion-okuri-max-length にしか無いので、主設定と
-- nvim-dev で同じ判定を共有する。
--
-- 上限が無いと読みを全ての位置で切って送りあり変換として引くため、
-- 「きんようびのよてい」では「き」+「んようびのよてい」まで試し、見出し
-- 「きn」の候補が「気んようびのよてい」… として補完一覧を埋める。
local M = {}

-- 試用中の上限。きつすぎる (長い活用形の補完が欲しい) なら 3、緩すぎるなら 1。
M.max_length = 2

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
  return src:find("completionOkuriMaxLength", 1, true) ~= nil
end

return M
