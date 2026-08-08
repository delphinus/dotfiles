-- skkeleton の completefunc (vim-skk/skkeleton#251) + completionBackend
-- (vim-skk/skkeleton#249) を組み合わせて試す環境。
--
--   NVIM_APPNAME=nvim-dev/skkeleton-completefunc nvim
--
-- 狙いは以下の連鎖が正しく回るかの確認:
--
--   <CR> → (eggLikeNewline + completionBackend "native") → <C-y>
--        → CompleteDone → skkeleton#complete_done() が残った ▽ を消す
--
-- #251 は ▽ をわざと補完範囲の外に置き、確定後に CompleteDone で消す設計な
-- ので、#249 で入れた confirm_key 経由の確定と噛み合うかは実際に踏まないと
-- 分からない。nvim-dev/skkeleton-native は ddc-ui-native 経由なのでこの経路は
-- 踏めず、この環境が要る。
--
-- ddc.vim も blink.cmp も使わない。候補を出すのは skkeleton の completefunc
-- だけ。
--
-- skkeleton は #251 をマージした専用の worktree を見る。無ければ以下で作る:
--
--   cd ~/.local/share/nvim/lazy/skkeleton
--   git fetch vim-skk 'refs/pull/251/head:pr-251'
--   git worktree add -b test/completefunc-x-backend \
--     ~/.local/share/nvim-dev/_worktrees/skkeleton-completefunc feat/completion-backend
--   cd ~/.local/share/nvim-dev/_worktrees/skkeleton-completefunc
--   git merge pr-251   # 衝突するのは doc/skkeleton.jax だけ (両方残す)

local shared = vim.env.HOME .. "/.local/share/nvim/lazy"
local skkeleton_dir = vim.env.HOME .. "/.local/share/nvim-dev/_worktrees/skkeleton-completefunc"

if not vim.uv.fs_stat(skkeleton_dir) then
  error(("skkeleton worktree が見付かりません: %s\n作り方はこのファイル冒頭のコメントを参照"):format(skkeleton_dir))
end

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

vim.g["denops#server#deno_args"] = { "-q", "--no-lock", "--unstable-kv", "-A" }

vim.opt.number = true
vim.opt.termguicolors = true
-- #251 の doc に従う。noinsert が無いと候補一覧を開いただけで先頭候補が挿入
-- され、選んでいない候補がユーザー辞書に登録される。longest / preinsert は
-- 禁止、情報表示は preview ではなく popup (preview だと WinLeave で skkeleton
-- が無効化される)。
vim.opt.completeopt = { "menu", "menuone", "noinsert", "popup" }
-- 候補が無いときの "Pattern not found" を抑制する
vim.opt.shortmess:append "c"

require("lazy").setup {
  {
    "vim-denops/denops.vim",
    dir = shared .. "/denops.vim",
    lazy = false,
  },

  {
    "vim-skk/skkeleton",
    dir = skkeleton_dir,
    lazy = false,
    dependencies = {
      "vim-denops/denops.vim",
      { "delphinus/skkeleton_indicator.nvim", dir = shared .. "/skkeleton_indicator.nvim", opts = { fadeOutMs = 0 } },
    },
    keys = {
      { "<A-j>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" } },
      { "<A-J>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" } },
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
    },
    config = function()
      local rank_file = vim.fs.normalize "~/.local/state/skkeleton/completion-rank.json"
      vim.fn.mkdir(vim.fs.dirname(rank_file), "p")

      vim.fn["skkeleton#config"] {
        userDictionary = vim.fs.normalize "~/git/github.com/delphinus/skk-jisyo/skk-jisyo.utf8",
        completionRankFile = rank_file,
        completionBackend = "native",
        eggLikeNewline = true,
        immediatelyCancel = false,
        registerConvertResult = true,
        sources = { "skk_server" },
        -- yaskkserv2 を --midashi-utf8 で起動しているため、見出しも UTF-8 で送る。
        skkServerReqEnc = "utf-8",
        skkServerResEnc = "utf-8",
        databasePath = vim.fn.stdpath "data" .. "/skkeleton.db",
      }
      vim.fn["skkeleton#register_kanatable"]("rom", {
        ["("] = { "（", "" },
        [")"] = { "）", "" },
        ["z "] = { "　", "" },
        ["<s-q>"] = "henkanPoint",
      })

      -- #251 の doc の例そのまま。completefunc は自動では設定されないので、
      -- skkeleton の有効・無効に合わせて自分で張り替える。
      local group = vim.api.nvim_create_augroup("skkeleton-completefunc", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "skkeleton-enable-post",
        callback = function()
          vim.b.saved_completefunc = vim.bo.completefunc
          vim.bo.completefunc = "skkeleton#completefunc"
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "skkeleton-disable-post",
        callback = function()
          vim.bo.completefunc = vim.b.saved_completefunc or ""
        end,
      })
      -- 確定後に残る ▽ を消す。skkeleton 由来でない候補は
      -- skkeleton#complete_done() 側で弾かれるので無条件に張ってよい。
      vim.api.nvim_create_autocmd("CompleteDone", {
        group = group,
        callback = function()
          vim.fn["skkeleton#complete_done"]()
        end,
      })
    end,
  },
}
