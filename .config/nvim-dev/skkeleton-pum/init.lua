-- skkeleton + pum.vim (ddc.vim) を試す環境。
-- skkeleton#config() の completionBackend = "pum.vim" の検証用。
--
--   NVIM_APPNAME=nvim-dev/skkeleton-pum nvim
--
-- skkeleton 以外の補完ソースは載せない。候補は skkeleton 同梱の ddc ソース
-- (denops/@ddc-sources/skkeleton{,_okuri}) だけが出し、UI は ddc-ui-pum 経由で
-- pum.vim が描画する。skkeleton から見えるのは pum#visible() /
-- pum#complete_info() なので、pum.vim バックエンドの経路をそのまま踏める。
--
-- 候補の選択には pum#map#select_relative() を使う (insert_relative だと候補を
-- 直接バッファへ挿し込んでしまい、skkeleton の pre-edit (▽…) と噛み合わない)。
-- 確定は skkeleton の pum.vim バックエンドが pum#map#confirm() を呼ぶ。
--
-- skkeleton 本体は ~/.local/share/nvim/lazy/skkeleton の作業ツリーを dir 指定
-- で共有する (nvim-dev/skkeleton と同じ)。ddc / pum まわりはこの NVIM_APPNAME
-- 専用の stdpath("data") に入るので主環境を汚さない。

local shared = vim.env.HOME .. "/.local/share/nvim/lazy"

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
        completionBackend = "pum.vim",
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
    end,
  },

  {
    "Shougo/ddc.vim",
    lazy = false,
    dependencies = {
      "vim-denops/denops.vim",
      "Shougo/pum.vim",
      "Shougo/ddc-ui-pum",
      -- 補完ソースは skkeleton 同梱のものだけ。ソース側でフィルタ・ソートまで
      -- 済ませる仕様なので ddc の matchers / sorters は入れない。
      { "vim-skk/skkeleton", dir = shared .. "/skkeleton" },
    },
    config = function()
      vim.fn["ddc#custom#patch_global"] {
        ui = "pum",
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

      -- pum.vim は自前のフローティングウィンドウなので選択も自前で行う。
      vim.keymap.set("i", "<C-n>", "<Cmd>call pum#map#select_relative(+1)<CR>")
      vim.keymap.set("i", "<C-p>", "<Cmd>call pum#map#select_relative(-1)<CR>")
      vim.keymap.set("i", "<C-y>", "<Cmd>call pum#map#confirm()<CR>")
      vim.keymap.set("i", "<C-e>", "<Cmd>call pum#map#cancel()<CR>")
    end,
  },
}
