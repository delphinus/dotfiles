-- skkeleton の completionOkuriMaxLength を ddc 経由で試す環境。
--
--   NVIM_APPNAME=nvim-dev/skkeleton-okuri-ddc nvim
--
-- 送りありの補完候補を出すのは ddc の skkeleton_okuri ソース。この設定を入れる
-- と、読みを全ての位置で切って作る見出しのうち送り仮名が長いものを捨てる。
-- 「きんようびのよてい」と入れて「気んようびのよてい」の類が並ばなくなることを
-- 見る。
--
-- 上限は挿入モードのまま切り替えられるので、同じ読みで前後を比べられる:
--
--   :call skkeleton#config(#{ completionOkuriMaxLength: 0 })   " 制限なし
--   :call skkeleton#config(#{ completionOkuriMaxLength: 2 })   " 送り仮名 2 文字まで
--
-- 辞書は L 辞書のみ。ユーザー辞書はこの NVIM_APPNAME 専用の場所に作るので、
-- 普段使っている ~/.skkeleton は汚れない。skk_server もデータベースも使わない。
-- nvim-dev/skkeleton-native から派生したが、あちらは skk_server 前提なので別に
-- してある。

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
-- noselect: 候補は自動確定せず <C-n> で選ぶ。
vim.opt.completeopt = { "menu", "menuone", "noselect" }

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
        eggLikeNewline = true,
      }
    end,
  },

  {
    "Shougo/ddc.vim",
    lazy = false,
    dependencies = {
      "vim-denops/denops.vim",
      "Shougo/ddc-ui-native",
      { "vim-skk/skkeleton", dir = shared .. "/skkeleton" },
    },
    config = function()
      -- doc/skkeleton.jax の |skkeleton-completion| の例そのまま。ソース側で
      -- 絞り込みと並べ替えまで済ませる仕様なので matchers / sorters は空。
      vim.fn["ddc#custom#patch_global"] {
        ui = "native",
        sources = { "skkeleton", "skkeleton_okuri" },
        sourceOptions = {
          _ = { matchers = {}, sorters = {}, converters = {} },
          skkeleton = {
            mark = "SKK",
            matchers = {},
            sorters = {},
            converters = {},
            isVolatile = true,
            minAutoCompleteLength = 1,
          },
          skkeleton_okuri = {
            mark = "SKK*",
            matchers = {},
            sorters = {},
            converters = {},
            isVolatile = true,
          },
        },
      }
      vim.fn["ddc#enable"]()
    end,
  },
}
