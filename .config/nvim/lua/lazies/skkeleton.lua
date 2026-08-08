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
  -- skkeleton の completionBackend (vim-skk/skkeleton#249) に backend 定義を
  -- 登録する自前ブランチを使用中。upstream (Xantibody) に入ったら branch 指定を
  -- 外して "Xantibody/blink-cmp-skkeleton" に戻す。
  -- event が要る。これが無いと「blink.cmp が候補ソースを計算する時に require
  -- される」まで読み込まれず、skkeleton の backend 登録が <C-j> に間に合わない
  -- (skkeleton が native にフォールバックして警告を出す)。blink.cmp 本体と同じ
  -- タイミングで載せる。
  {
    "delphinus/blink-cmp-skkeleton",
    branch = "feat/skkeleton-completion-backend",
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
      -- blink 使用時の <CR> 確定は skkeleton 本体の completionBackend が面倒を
      -- 見るため、以前ここにあった buffer-local <CR> 張り替えハックは不要。
      if use_cmp then
        require("core.skkeleton_cmp").setup()
      end

      -- 補完候補の並び順学習 (getRanks) を永続化する。デフォルト ("") では
      -- denops プロセスのメモリ内にしか乗らず、再起動・別インスタンスで失われる。
      -- nvim / nvim-dev でランクを共有したいので stdpath ("state") (NVIM_APPNAME
      -- 依存) ではなく固定パスにする。Deno.writeTextFile は親ディレクトリを
      -- 作らないので Lua 側で先に掘っておく。
      local rank_file = vim.fs.normalize "~/.local/state/skkeleton/completion-rank.json"
      vim.fn.mkdir(vim.fs.dirname(rank_file), "p")

      -- blink-cmp-skkeleton の補完取得を診断するためのログ出力先 (skk_server の
      -- ソケット応答ズレ調査用)。補完が出なくなったら再起動せずにこのファイルを
      -- 確認する。原因特定後に削除予定。
      vim.g.blink_cmp_skkeleton_debug_file = vim.fs.normalize "~/.local/state/skkeleton/blink-skk-debug.log"

      vim.fn["skkeleton#config"] {
        userDictionary = vim.fs.normalize "~/git/github.com/delphinus/skk-jisyo/skk-jisyo.utf8",
        completionRankFile = rank_file,
        completionBackend = use_cmp and "nvim-cmp" or "blink.cmp",
        eggLikeNewline = true,
        immediatelyCancel = false,
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
