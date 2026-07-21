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
  -- 補完取得を非同期化した自前ブランチ (Xantibody#19) を使用中。マージされたら
  -- branch 指定を外して "Xantibody/blink-cmp-skkeleton" に戻す。
  { "delphinus/blink-cmp-skkeleton", branch = "feat/async-completion", enabled = not use_cmp },

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
    "vim-skk/skkeleton",
    lazy = false,
    keys = skkeleton_keys,
    dependencies = { "denops.vim" },

    config = function()
      if use_cmp then
        require("core.skkeleton_cmp").setup()
      else
        -- skkeleton#map sets a buffer-local <nowait> <CR> that shadows blink's
        -- global mapping. Re-override after enable to delegate to blink when
        -- its menu is visible.
        local group = vim.api.nvim_create_augroup("skkeleton_blink_cr", {})
        vim.api.nvim_create_autocmd("User", {
          group = group,
          pattern = "skkeleton-enable-post",
          callback = function()
            vim.keymap.set("i", "<CR>", function()
              local ok, blink = pcall(require, "blink.cmp")
              if ok and blink.is_visible() then
                blink.select_and_accept()
                return
              end
              vim.fn["skkeleton#handle"]("handleKey", { key = vim.keycode "<CR>" })
            end, { buffer = true, nowait = true, desc = "blink + skkeleton <CR>" })
          end,
        })
        vim.api.nvim_create_autocmd("User", {
          group = group,
          pattern = "skkeleton-disable-pre",
          callback = function()
            pcall(vim.keymap.del, "i", "<CR>", { buffer = true })
          end,
        })
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
