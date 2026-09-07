local utils = require "core.utils"
local lazy_require = require "lazy_require"

local use_cmp = not not vim.env.CMP

local skkeleton_keys = {
  { "<A-j>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" } },
  { "<A-J>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" } },
  { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
}
if use_cmp then
  table.insert(
    skkeleton_keys,
    { "<C-x><C-o>", lazy_require("cmp").complete(), mode = { "i" }, desc = "Complete by nvim-cmp" }
  )
end

return {
  { "uga-rosa/cmp-skkeleton", enabled = use_cmp, event = { "InsertEnter", "CmdlineEnter" } },
  -- 自前ブランチを使用中。2 つの機能が積んである:
  --   feat/skkeleton-completion-backend  skkeleton の completionBackend
  --     (vim-skk/skkeleton#249) に backend 定義を登録する
  --   feat/learn-on-implicit-confirm     ↑の上。候補を選んだまま打ち続けて確定
  --     した分を学習する (他の SKK 実装と同じ自動確定)。これが無いと <CR> を
  --     押さない限り候補の順位が永久に上がらない
  -- upstream (Xantibody) に両方入ったら branch 指定を外して
  -- "Xantibody/blink-cmp-skkeleton" に戻す。
  -- event が要る。これが無いと「blink.cmp が候補ソースを計算する時に require
  -- される」まで読み込まれず、skkeleton の backend 登録が <C-j> に間に合わない
  -- (skkeleton が native にフォールバックして警告を出す)。blink.cmp 本体と同じ
  -- タイミングで載せる。
  {
    "delphinus/blink-cmp-skkeleton",
    branch = "feat/learn-on-implicit-confirm",
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
    -- 補完エンジン連携を登録制にした自前ブランチを使用中 (vim-skk/skkeleton#249
    -- の提案 B)。skkeleton#register_completion_backend() で補完エンジンを登録し、
    -- completionBackend で選ぶと eggLikeNewline 有効時の <CR> 確定が効く。
    -- blink.cmp 用の backend 定義は blink-cmp-skkeleton 側が登録する。
    -- upstream にマージされたら branch 指定を外して "vim-skk/skkeleton" に戻す。
    "delphinus/skkeleton",
    branch = "feat/completion-backend",
    lazy = false,
    keys = skkeleton_keys,
    dependencies = { "denops.vim" },

    config = function()
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

      vim.fn["skkeleton#config"] {
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
