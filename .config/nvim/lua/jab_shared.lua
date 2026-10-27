-- Shared jab.nvim keymaps reused by the main nvim config and the
-- nvim-dev/{codediff,skkeleton} sub-configs. The dev configs prepend this
-- file's directory to package.path so they can `require("jab_shared")` the
-- same table the main config uses (同じ作法は blink_shared.lua も参照)。
--
-- flash.nvim からの移行。対応関係:
--   s        jab_win()  flash.jump() 相当のウィンドウ内インクリメンタル検索 (migemo)
--
-- f/F/t/T は jab には割り当てず、組込みのままにしている。jab の f は候補が
-- 2 つ以上あると最寄りでもラベル入力を求め、; / , でも繰り返せなかったため。
-- 代わりにメイン config と nvim-dev/skkeleton では eyeliner.nvim で f 一発で
-- 届く文字を示す (lua/eyeliner_shared.lua 参照)。
--
-- flash.nvim にあった treesitter() / remote() / treesitter_search() / toggle()
-- は jab に無いため移行していない。
--
-- 既知の制限 (flash との差):
--   1. (解決済み) jab_win (s) を multi_window = true でタブ内の全可視ウィンドウ
--      対象にできるようになった (delphinus/jab.nvim feat/multi-window)。下の
--      keys で有効化済み。buffer 単位でまとめてラベル付けし、カレント優先で
--      ラベルを割り当て、別ウィンドウへも飛べる (operator 待機中は 1 window)。
--   2. jab_win は可視ウィンドウを上から下へ走査してラベルを頭から割り当て、
--      ラベル在庫が尽きたら打ち切る。カーソルからの距離順ではないので、
--      マッチが多いとカーソル近傍 (下側) にラベルが付かないことがある。
--      回避: クエリを 1〜2 文字伸ばして候補を絞る。flash はマッチをカーソル
--      距離順にソートしてラベルを振っていた。

local M = {}

-- lazy.nvim の keys 用リスト。プラグイン本体の指定 (name / dir / dependencies)
-- は config ごとに異なるので、共通なのはこのキー定義だけ。
M.keys = {
  {
    "s",
    function()
      return require("jab").jab_win {
        labels = vim.split("HJKLASDFGYUIOPQWERTNMZXCVBhjklasdfgyuiopqwertnmzxcvb", ""),
        multi_window = true, -- タブ内の全可視ウィンドウを対象にする (flash.jump 相当)
      }
    end,
    mode = { "n", "x", "o" },
    expr = true,
  },
}

return M
