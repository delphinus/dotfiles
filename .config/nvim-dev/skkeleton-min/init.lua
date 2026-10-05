-- skkeleton (upstream main) + SKK-JISYO.L だけの最小構成。本体の挙動を手元の
-- 設定から切り離して確かめるための環境で、確定アンドゥ (kakuteiUndo) の検証に
-- 使っている。
--
--   NVIM_APPNAME=nvim-dev/skkeleton-min nvim
--
-- 他の nvim-dev/skkeleton* との違い:
--
--   * skkeleton を dir 共有しない。~/.local/share/nvim/lazy/skkeleton は自分の
--     ブランチ (と作業中の変更) が載っているので、ここでは lazy に
--     vim-skk/skkeleton の main を別途 clone させる。denops.vim も同じ。
--     upstream に報告する挙動はこちらで再現できたものだけにする。
--   * 辞書は SKK-JISYO.L だけ。辞書サーバも Google 日本語入力も使わない。
--   * 補完エンジンを載せない。補完は Vim/Neovim の組み込み補完
--     (|ins-completion|) だけを使う。ddc も blink.cmp も入れないので、補完に
--     よる確定も skkeleton 本体の挙動として見られる。
--   * ユーザ辞書・学習はこの NVIM_APPNAME の state 配下に閉じる。主環境の
--     skk-jisyo レポジトリには触らない。
--
-- 確定アンドゥの手順 (「決める」と書こうとして別の候補で確定した場合):
--
--   <C-j> KiMe   →  ▼△△め (送りあり変換。候補は <Space> で送る)
--   <CR>         →  確定
--   ru           →  △△める
--   <C-h>        →  る を消す
--   <C-z>        →  ▼△△め に戻る (確定した文字列がカーソル直前に残っている
--                    ときだけ動く)
--
-- 補完による確定を試す手順:
--
--   <C-j> Ho       →  ▽ほ
--   <C-x><C-u>     →  候補一覧 (補完/補間/…)
--   <C-n> <CR>     →  候補を選んで確定 (▼ を経ずに入る)
--   <C-z>          →  ▼ に戻る (確定した候補の見出しに対する変換候補が並ぶ)

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

vim.opt.number = true
vim.opt.termguicolors = true

-- 組み込み補完の設定。noinsert が無いと候補一覧を開いただけで先頭の候補が入り、
-- 選んでいない候補が学習される。longest と preinsert は skkeleton の pre-edit と
-- ずれるので指定しない。候補が無いときの "Pattern not found" は shortmess で消す。
vim.opt.completeopt = { "menu", "menuone", "popup", "noinsert" }
vim.opt.shortmess:append "c"

-- SKK-JISYO.L は ghq でクローンした skk-dev/dict のもの。EUC-JP だが skkeleton
-- が自動判定するのでエンコーディングは指定しない。
local jisyo = vim.fs.normalize "~/git/github.com/skk-dev/dict/SKK-JISYO.L"
if not vim.uv.fs_stat(jisyo) then
  vim.notify(
    ("SKK-JISYO.L が無い: %s\nghq get https://github.com/skk-dev/dict で取得する"):format(jisyo),
    vim.log.levels.ERROR
  )
end

-- 学習内容の置き場所。stdpath は NVIM_APPNAME 込みなので
-- ~/.local/state/nvim-dev/skkeleton-min/ に閉じる。
local user_jisyo = vim.fn.stdpath "state" .. "/skkeleton-jisyo.utf8"
vim.fn.mkdir(vim.fs.dirname(user_jisyo), "p")

-- 直したものを試すときだけ、別のチェックアウト (worktree など) に差し替える。
-- 指定が無ければ lazy が clone した upstream の main を使う。
--
--   SKKELETON_DIR=~/.local/share/claude-worktrees/skkeleton-foo \
--     NVIM_APPNAME=nvim-dev/skkeleton-min nvim
local skkeleton_dir = vim.env.SKKELETON_DIR and vim.fs.normalize(vim.env.SKKELETON_DIR) or nil

require("lazy").setup {
  { "vim-denops/denops.vim", lazy = false },

  {
    "vim-skk/skkeleton",
    branch = "main",
    dir = skkeleton_dir,
    dependencies = { "vim-denops/denops.vim" },
    lazy = false,
    keys = {
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
    },
    config = function()
      vim.fn["skkeleton#config"] {
        globalDictionaries = { jisyo },
        userDictionary = user_jisyo,
        -- ▼ の状態で <CR> を押したときに改行を入れず確定だけ行う。既定 (false)
        -- だと確定と同時に改行が入って行が変わり、確定の記録がそこで捨てられる
        -- ため確定アンドゥが動かなくなる。主環境に合わせて true にしてある。
        eggLikeNewline = true,
      }

      -- 確定アンドゥ。mapped_keys に足さないとバッファローカルなマッピングが
      -- 張られず、キーが skkeleton まで届かない。
      vim.g["skkeleton#mapped_keys"] = vim.list_extend(vim.g["skkeleton#mapped_keys"], { "<C-z>" })
      vim.fn["skkeleton#register_keymap"]("input", "<C-z>", "kakuteiUndo")

      -- 組み込み補完 (|ins-completion|) で補完する。doc/skkeleton.jax の
      -- |skkeleton-completion| にある例のまま。skkeleton は既存の設定を壊さない
      -- よう 'completefunc' を自動では設定しないので、有効化・無効化に合わせて
      -- こちらで張り替える。完了時の後始末 (▽ の削除・確定の通知) は
      -- CompleteDone から skkeleton#complete_done() を呼んで行う。
      --
      -- completionBackend は既定の "native" のまま。これで補完メニューを開いた
      -- ままの <CR> が候補の確定になる (eggLikeNewline)。
      local group = vim.api.nvim_create_augroup("skkeleton-min-completefunc", {})
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "skkeleton-enable-post",
        callback = function()
          vim.b.skkeleton_min_completefunc = vim.bo.completefunc
          vim.bo.completefunc = "skkeleton#completefunc"
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "skkeleton-disable-post",
        callback = function()
          vim.bo.completefunc = vim.b.skkeleton_min_completefunc or ""
        end,
      })
      vim.api.nvim_create_autocmd("CompleteDone", {
        group = group,
        callback = function()
          vim.fn["skkeleton#complete_done"]()
        end,
      })
    end,
  },
}
