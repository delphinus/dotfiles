local utils = require "core.utils"
local lazy_require = require "lazy_require"

local use_cmp = not not vim.env.CMP

-- "t" (ターミナルモード) も張る。skkeleton は <Plug> を noremap! と tnoremap の
-- 2 系統で定義しており (plugin/skkeleton.vim)、skkeleton#map() は有効化した時の
-- mode() を見てキーを張るので、端末で使うには端末で有効化する必要がある。挿入
-- モードで有効化した状態は inoremap なので端末には効かない。
-- なお端末モードでは補完が無効で、入力は端末アプリへの送信 (<BS> を送ってから
-- 書き直す) で再現されるため、アプリによっては表示が崩れる。
local skkeleton_keys = {
  { "<A-j>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l", "t" } },
  { "<A-J>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l", "t" } },
  { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l", "t" } },
}
if use_cmp then
  table.insert(
    skkeleton_keys,
    { "<C-x><C-o>", lazy_require("cmp").complete(), mode = { "i" }, desc = "Complete by nvim-cmp" }
  )
end

return {
  -- 自前ブランチを使用中。feat/register-completion-backend が nvim-cmp を
  -- skkeleton の補完バックエンドとして登録する (uga-rosa/cmp-skkeleton#4)。
  -- skkeleton 本体から nvim-cmp / pum.vim の backend 定義が外れた
  -- (vim-skk/skkeleton#253) ぶんの受け皿で、これが無いと completionBackend の
  -- "nvim-cmp" が native にフォールバックし、eggLikeNewline の <CR> で補完候補を
  -- 確定できない。blink 側で blink-cmp-skkeleton がやっているのと同じこと。
  -- upstream にマージされたら branch 指定を外して "uga-rosa/cmp-skkeleton" に戻す。
  -- fork のレポジトリ名が cmp-skkeleton2 なので、name でプラグイン名を元に揃える。
  {
    "delphinus/cmp-skkeleton2",
    name = "cmp-skkeleton",
    branch = "feat/register-completion-backend",
    enabled = use_cmp,
    event = { "InsertEnter", "CmdlineEnter" },
  },
  -- 自前の統合ブランチ (test/kakutei-undo+okuriari) を使用中。upstream
  -- (Xantibody/main) の上に 4 つの機能が積んである:
  --   feat/skkeleton-completion-backend  skkeleton の completionBackend
  --     (vim-skk/skkeleton#249) に backend 定義を登録する
  --   feat/learn-on-implicit-confirm     ↑の上。候補を選んだまま打ち続けて確定
  --     した分を学習する (他の SKK 実装と同じ自動確定)。これが無いと <CR> を
  --     押さない限り候補の順位が永久に上がらない
  --   feat/kakutei-undo-inserted         ↑の上。completeCallback にバッファへ
  --     挿入した文字列を渡す。これが無いと補完による確定を kakuteiUndo で
  --     取り消せない
  --   feat/okuriari-completion           ↑の上。getCompleteItems に切り替えて
  --     送りありの候補も出す (ddc の skkeleton_okuri ソース相当)。skkeleton
  --     3.0.0 以降が要る
  -- PR は各ブランチから出す。この統合ブランチからは出さない。
  -- upstream (Xantibody) に全部入ったら branch 指定を外して
  -- "Xantibody/blink-cmp-skkeleton" に戻す。
  -- event が要る。これが無いと「blink.cmp が候補ソースを計算する時に require
  -- される」まで読み込まれず、skkeleton の backend 登録が <C-j> に間に合わない
  -- (skkeleton が native にフォールバックして警告を出す)。blink.cmp 本体と同じ
  -- タイミングで載せる。
  {
    "delphinus/blink-cmp-skkeleton",
    branch = "test/kakutei-undo+okuriari",
    enabled = not use_cmp,
    event = { "InsertEnter", "CmdlineEnter" },
  },

  {
    "willelz/skk-tutorial.vim",
    cmd = { "SKKTutorialStart" },
    dependencies = { "denops.vim", "skkeleton" },
    config = function()
      utils.load_denops_plugin "skk-tutorial.vim"
      vim.wait(1000, function()
        return not not vim.api.nvim_get_commands({}).SKKTutorialStart
      end)
    end,
  },

  {
    -- 自前ブランチ feat/completion-okuri-max-length を使用中。補完で送り仮名と
    -- みなす長さの上限 (completionOkuriMaxLength) を足すもので、下の
    -- core.skkeleton_okuri_limit で値を渡している。upstream にマージされたら
    -- branch 指定を外して "vim-skk/skkeleton" に戻す。
    -- 確定アンドゥ (vim-skk/skkeleton#257) は 2026-09-14 に upstream へマージ
    -- 済みで、このブランチは main の上に乗っている。補完エンジン連携の登録制
    -- (同 #253) も同様。下の register_keymap で <C-z> に割り当てている。
    -- 手元のクローン (~/.local/share/nvim/lazy/skkeleton) は origin を fork
    -- (delphinus/skkeleton) に向けておくこと。lazy.nvim は spec の URL と
    -- origin が食い違うとディレクトリを消して clone し直すので、vim-skk を
    -- 向いたままの端末では worktree ごと消える:
    --   git -C ~/.local/share/nvim/lazy/skkeleton remote rename origin vim-skk
    --   git -C ~/.local/share/nvim/lazy/skkeleton remote rename delphinus origin
    "delphinus/skkeleton",
    branch = "feat/completion-okuri-max-length",
    lazy = false,
    keys = skkeleton_keys,
    dependencies = { "denops.vim" },

    config = function(plugin)
      -- 左右の ⌘ 単体押しでかな・英数を切り替えるための Karabiner 連携。補完
      -- エンジンに依らず常に要る (CMP=1 の時だけ有効になっていて壊れていた)。
      require("core.skkeleton_karabiner").setup()

      -- blink 使用時の <CR> 確定は skkeleton 本体の completionBackend が面倒を
      -- 見るため、以前ここにあった buffer-local <CR> 張り替えハックは不要。
      if use_cmp then
        require("core.skkeleton_cmp").setup()
      end

      -- 補完候補の並び順学習 (getRanks) を永続化する。デフォルト ("") では
      -- denops プロセスのメモリ内にしか乗らず、再起動・別インスタンスで失われる。
      -- nvim / nvim-dev でランクを共有したいので stdpath ("state") (NVIM_APPNAME
      -- 依存) ではなく固定パスにする。
      --
      -- 置き場所は userDictionary と同じ skk-jisyo レポジトリ。以前は
      -- ~/.local/state/skkeleton/ に置いていたが、それだと端末ごとに独立して
      -- しまい、仕事の Mac で覚えた語が自宅の Mac の補完で埋もれる (実測で共通
      -- 1361 語のうち隣接ペアの 49% が逆順だった)。レポジトリに置けば git-crypt
      -- と merge driver にそのまま乗り、bin/merge-completion-rank が 3-way で
      -- マージする。MacSKK 側のランクは辞書の行順そのものなので無関係。
      local skk_repo = vim.fs.normalize "~/git/github.com/delphinus/skk-jisyo"
      local rank_file = skk_repo .. "/completion-rank.json"

      local skk_config = {
        userDictionary = skk_repo .. "/skk-jisyo.utf8",
        completionRankFile = rank_file,
        completionBackend = use_cmp and "nvim-cmp" or "blink.cmp",
        eggLikeNewline = true,
        immediatelyCancel = false,
        -- 1 回目の <Space> から候補一覧を出す (macSKK の inlineCandidateCount = 0
        -- 相当)。既定の 4 は 5 回目から。0 にすると最初からページ送りになるので、
        -- 候補選択は selectCandidateKeys で行う。
        showCandidatesCount = 0,
        -- 候補の確定キー。既定の asdfjkl は ▼ 中に打った仮名が候補を確定させて
        -- しまうので、macSKK 既定の "123456789" に倣って数字にする。skkeleton は
        -- 7 文字固定なので 1〜7 まで。
        selectCandidateKeys = "1234567",
        registerConvertResult = true,
        sources = { "skk_server" }, -- use yaskkserv2
        -- yaskkserv2 を --midashi-utf8 で起動しているため、見出しも UTF-8 で送る。
        skkServerReqEnc = "utf-8",
        skkServerResEnc = "utf-8",
        databasePath = vim.fn.stdpath "data" .. "/skkeleton.db",
      }

      -- 補完で送り仮名とみなす長さの上限。fork のブランチにしか無いオプション
      -- なので、チェックアウトが持っているときだけ渡す (判定の理由はモジュール
      -- 側のコメント)。
      local okuri_limit = require "core.skkeleton_okuri_limit"
      if okuri_limit.supported(plugin.dir) then
        skk_config.completionOkuriMaxLength = okuri_limit.max_length
      end

      vim.fn["skkeleton#config"](skk_config)

      -- 確定アンドゥ (vim-skk/skkeleton#165)。候補を選び間違えて確定した時に、
      -- 読みから打ち直さず ▼ の状態へ戻して選び直す。確定した文字列がカーソル
      -- 直前に残っている時だけ効き、それ以外では何も起きない。
      -- <C-z> は挿入モードでは未使用なので何も奪わない (<C-u> は「入力した文字を
      -- 全消し」に使われている)。macSKK のトグル変換もどき (fixNextCandidate) も
      -- 同じ ⌃Z に割り当てている。
      -- mapped_keys に足さないとバッファローカルなマッピングが張られず、キーが
      -- skkeleton まで届かない (既定のリストは英数字と記号、<BS> 等のみ)。
      vim.g["skkeleton#mapped_keys"] = vim.list_extend(vim.g["skkeleton#mapped_keys"], { "<C-z>" })
      vim.fn["skkeleton#register_keymap"]("input", "<C-z>", "kakuteiUndo")

      vim.fn["skkeleton#register_kanatable"]("rom", {
        ["("] = { "（", "" },
        [")"] = { "）", "" },
        ["z "] = { "　", "" },
        ["z1"] = { "①", "" },
        ["z2"] = { "②", "" },
        ["z3"] = { "③", "" },
        ["z4"] = { "④", "" },
        ["z5"] = { "⑤", "" },
        ["z6"] = { "⑥", "" },
        ["z7"] = { "⑦", "" },
        ["z8"] = { "⑧", "" },
        ["z9"] = { "⑨", "" },
        ["<s-q>"] = "henkanPoint",
      })
    end,
  },
}
