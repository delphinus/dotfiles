-- Shared jab.nvim keymaps reused by the main nvim config and the
-- nvim-dev/{codediff,skkeleton} sub-configs. The dev configs prepend this
-- file's directory to package.path so they can `require("jab_shared")` the
-- same table the main config uses (同じ作法は blink_shared.lua も参照)。
--
-- flash.nvim からの移行。対応関係:
--   s        jab_win()  flash.jump() 相当のウィンドウ内インクリメンタル検索 (migemo)
--   f/F/t/T             jab 独自の label hint 付き・dot-repeat 対応モーション
--                       (flash では素の f/F/t/T のままだった)。count 指定時
--                       (例: 1fx) は組込みの f/F/t/T に委ねる (下の fmotion 参照)。
--
-- flash.nvim にあった treesitter() / remote() / treesitter_search() / toggle()
-- は jab に無いため移行していない。
--
-- 既知の制限 (flash との差。いずれも jab 側の改修が要る upstream 事項で、
-- 将来 issue/PR にまとめる候補):
--   1. jab_win (s) は現在のウィンドウ 1 つだけが対象。flash.jump は既定で
--      タブページ内の全可視ウィンドウにラベルを付けて別ウィンドウへも飛べた。
--      jab は nvim_tabpage_list_wins を使わず単一ウィンドウ固定 (init.lua の
--      opts.win = nvim_get_current_win / search_inwindow が 1 window のみ走査)。
--   2. jab_win は可視ウィンドウを上から下へ走査してラベルを頭から割り当て、
--      ラベル在庫が尽きたら打ち切る。カーソルからの距離順ではないので、
--      マッチが多いとカーソル近傍 (下側) にラベルが付かないことがある。
--      回避: クエリを 1〜2 文字伸ばして候補を絞る。flash はマッチをカーソル
--      距離順にソートしてラベルを振っていた。

local M = {}

-- f/F/t/T 用のマッピングを作る。count を明示したとき (例: 1fx / 2fx) は
-- 組込みの f/F/t/T にフォールバックする。jab は f 系を完全に置き換えるが、
-- たまに素の挙動 (特に ; / , での繰り返し) が欲しいので、カウント指定時だけ
-- native に委ねる。参考:
-- https://blog.atusy.net/2025/10/03/switch-to-native-mapping-with-count/
local function fmotion(key)
  return {
    key,
    function()
      if vim.v.count > 0 then
        return key
      end
      return require("jab")[key]()
    end,
    mode = { "n", "x", "o" },
    expr = true,
  }
end

-- lazy.nvim の keys 用リスト。プラグイン本体の指定 (name / dir / dependencies)
-- は config ごとに異なるので、共通なのはこのキー定義だけ。
M.keys = {
  {
    "s",
    function()
      return require("jab").jab_win {
        labels = vim.split("HJKLASDFGYUIOPQWERTNMZXCVB", ""),
      }
    end,
    mode = { "n", "x", "o" },
    expr = true,
  },
  fmotion "f",
  fmotion "F",
  fmotion "t",
  fmotion "T",
}

return M
