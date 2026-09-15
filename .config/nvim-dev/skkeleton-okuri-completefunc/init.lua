-- skkeleton の completionOkuriMaxLength を native completefunc で試す環境。
--
--   NVIM_APPNAME=nvim-dev/skkeleton-okuri-completefunc nvim
--
-- ddc.vim も blink.cmp も載せない。候補を出すのは skkeleton#completefunc() だけ
-- で、送りなしと送りありの候補をまとめて返す。挿入モードで読みを入れてから
-- <C-x><C-u> で補完する。
--
-- <F2> で出し方を切り替えられる (挿入モードのままでも押せる):
--
--   手動 (既定): 'completefunc' だけを張る。<C-x><C-u> で出す
--   自動:        'complete' の F フラグ + 'autocomplete' で打つそばから出す
--
-- 自動は 'complete' 経由なので doc の制限が乗る。送りの開始に大文字を使った
-- pre-edit (▽おく*r) では候補の先頭が欠けるので、読みは最後までひらがなで
-- 入れる。
--
-- 上限は挿入モードのまま切り替えられるので、同じ読みで前後を比べられる:
--
--   :call skkeleton#config(#{ completionOkuriMaxLength: 0 })   " 制限なし
--   :call skkeleton#config(#{ completionOkuriMaxLength: 2 })   " 送り仮名 2 文字まで
--
-- 辞書は L 辞書のみ。ユーザー辞書はこの NVIM_APPNAME 専用の場所に作るので、
-- 普段使っている ~/.skkeleton は汚れない。skk_server もデータベースも使わない。
-- nvim-dev/skkeleton-completefunc から派生したが、あちらは #251 用の worktree を
-- 見に行くので別にしてある。

local shared = vim.env.HOME .. "/.local/share/nvim/lazy"

local dict = vim.fs.normalize "~/git/github.com/skk-dev/dict/SKK-JISYO.L"
if not vim.uv.fs_stat(dict) then
  error(
    ("L 辞書が見付かりません: %s\nghq get https://github.com/skk-dev/dict で取得してください"):format(
      dict
    )
  )
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

vim.g["denops#server#deno_args"] = { "-q", "--no-lock", "-A" }

vim.opt.number = true
vim.opt.termguicolors = true
-- doc/skkeleton.jax の |skkeleton-completion| に従う。noinsert が無いと候補一覧を
-- 開いただけで先頭候補が挿入され、選んでいない候補がユーザー辞書に登録される。
-- longest / preinsert は禁止、情報表示は preview ではなく popup (preview だと
-- WinLeave で skkeleton が無効化される)。
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
    dir = shared .. "/skkeleton",
    lazy = false,
    dependencies = { "vim-denops/denops.vim" },
    keys = {
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
    },
    config = function()
      vim.fn["skkeleton#config"] {
        globalDictionaries = { dict },
        userDictionary = vim.fn.stdpath "state" .. "/skkeleton/userjisyo",
        completionOkuriMaxLength = 2,
        completionBackend = "native",
        eggLikeNewline = true,
      }

      -- 自動 ('complete' の F フラグ + 'autocomplete') かどうか。<F2> で切り替える。
      local auto = false

      -- skkeleton が有効なバッファにだけ 'complete' を張る。無効なバッファに
      -- 残すと skkeleton と関係ない補完まで completefunc を呼んでしまう。
      local function apply_auto()
        if auto and vim.bo.completefunc == "skkeleton#completefunc" then
          if vim.b.saved_complete == nil then
            vim.b.saved_complete = vim.bo.complete
          end
          vim.bo.complete = "Fskkeleton#completefunc"
          vim.bo.autocomplete = true
        else
          if vim.b.saved_complete ~= nil then
            vim.bo.complete = vim.b.saved_complete
            vim.b.saved_complete = nil
          end
          vim.bo.autocomplete = false
        end
      end

      vim.keymap.set({ "n", "i" }, "<F2>", function()
        auto = not auto
        -- 'autocomplete' と併せるときは noselect を明示する (doc の指示)。
        if auto then
          vim.opt.completeopt:append "noselect"
        else
          vim.opt.completeopt:remove "noselect"
        end
        apply_auto()
        vim.notify(auto and "補完: 自動 ('complete' の F + 'autocomplete')" or "補完: 手動 (<C-x><C-u>)")
      end, { desc = "skkeleton: 補完の出し方を切り替える" })

      -- completefunc は自動では設定されないので、skkeleton の有効・無効に
      -- 合わせて自分で張り替える。
      local group = vim.api.nvim_create_augroup("skkeleton-completefunc", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "skkeleton-enable-post",
        callback = function()
          vim.b.saved_completefunc = vim.bo.completefunc
          vim.bo.completefunc = "skkeleton#completefunc"
          apply_auto()
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "skkeleton-disable-post",
        callback = function()
          vim.bo.completefunc = vim.b.saved_completefunc or ""
          apply_auto()
        end,
      })
      -- 確定後に残る ▽ を消す。
      vim.api.nvim_create_autocmd("CompleteDone", {
        group = group,
        callback = function()
          vim.fn["skkeleton#complete_done"]()
        end,
      })
    end,
  },
}
