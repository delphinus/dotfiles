-- Shougo/goda.vim と goda-cmp.vim を試す環境。
--
--   NVIM_APPNAME=nvim-dev/goda nvim
--
-- goda.vim は denops.vim の Deno を Go に置き換えたもの。プラグインは Go の
-- バイナリで、goda-cmp.vim はその上に作られた ddc.vim の後継にあたる補完。
-- 設定は ddc.ts の代わりに Go のモジュールとして書き、ビルドしたバイナリを
-- goda.vim が起動する。モジュールは隣の goda-cmp/ にある (Neovim の既定の
-- stdpath('config')/goda-cmp)。バイナリは stdpath('cache')/goda-cmp に出来る。
--
-- 初回の起動でバイナリが無ければ goda_cmp#build() を呼んでから有効にする。
-- goda-cmp/*.go を保存すると作り直して再起動する。上手く動かないときは
--
--   :echo goda#log()
--
-- でバイナリの標準エラー出力を見る。
--
-- UI は pum.vim と組込みのポップアップの両方を入れてあり、既定は pum。
-- 組込みに切り替えて比べるには
--
--   :call goda_cmp#patch_global(#{ ui: 'native' })
--
-- Go のファイルでは gopls を goda-cmp 自身が起動する (Neovim の LSP クライアン
-- トは使わない)。gopls は mason のものを PATH に足して使う。
--
-- 定義ジャンプなどのために、Neovim の LSP クライアントでも gopls を別に起動す
-- る。こちらは補完に使わない (vim.lsp.completion を有効にすると goda-cmp と候
-- 補が二重に出る)。gd で定義へ飛ぶほか、Neovim の既定のキー (<C-]>、K、grr、
-- grn など) も使える。

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

-- goda-cmp が起動する gopls はこの PATH を引き継ぐ。
vim.env.PATH = vim.env.HOME .. "/.local/share/nvim/mason/bin:" .. vim.env.PATH

vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append "c"

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod" },
  root_markers = { "go.work", "go.mod", ".git" },
})
vim.lsp.enable "gopls"
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP の定義へ飛ぶ" })

local config_dir = vim.fn.stdpath "config" .. "/goda-cmp"

local function setup_keys()
  local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true }, opts or {}))
  end

  -- 挿入モード。examples/ddc/vimrc.vim から抜粋した。
  map("i", "<C-n>", "<Cmd>call pum#map#insert_relative(+1)<CR>")
  map("i", "<C-p>", "<Cmd>call pum#map#insert_relative(-1)<CR>")
  map("i", "<C-y>", "<Cmd>call pum#map#confirm()<CR>")
  map("i", "<C-e>", "<Cmd>call pum#map#cancel()<CR>")
  map("i", "<Tab>", function()
    if vim.fn["pum#visible"]() then
      return [[<Cmd>call pum#map#insert_relative(+1, "empty")<CR>]]
    end
    local col = vim.fn.col "."
    if col <= 1 or vim.fn.getline("."):sub(col - 1, col - 1):match "%s" then
      return "<Tab>"
    end
    return vim.fn["goda_cmp#map#manual_complete"]()
  end, { expr = true })
  map("i", "<S-Tab>", [[<Cmd>call pum#map#insert_relative(-1, "empty")<CR>]])

  -- コマンドラインの補完。: を押したときだけ有効にし、抜けたら外す。
  local cmdline_keys = {
    ["<Tab>"] = "<Cmd>call pum#map#insert_relative(+1)<CR>",
    ["<S-Tab>"] = "<Cmd>call pum#map#insert_relative(-1)<CR>",
    ["<C-y>"] = "<Cmd>call pum#map#confirm()<CR>",
    ["<C-e>"] = "<Cmd>call pum#map#cancel()<CR>",
  }
  local function cmdline_pre()
    for lhs, rhs in pairs(cmdline_keys) do
      map("c", lhs, rhs, { buffer = true })
    end
    vim.api.nvim_create_autocmd("User", {
      pattern = "GodaCmpCmdlineLeave",
      once = true,
      callback = function()
        for lhs in pairs(cmdline_keys) do
          pcall(vim.keymap.del, "c", lhs, { buffer = true })
        end
      end,
    })
    vim.fn["goda_cmp#enable_cmdline"]()
  end
  map({ "n", "x" }, ":", function()
    cmdline_pre()
    return ":"
  end, { expr = true, silent = false })
end

local function enable()
  local binary = vim.g["goda_cmp#binary"] or (vim.fn.stdpath "cache" .. "/goda-cmp")
  if not vim.uv.fs_stat(binary) then
    vim.notify("goda-cmp: バイナリをビルドしています…", vim.log.levels.INFO)
    vim.fn["goda_cmp#build"]()
  end
  vim.fn["goda_cmp#enable"]()
end

require("lazy").setup({
  {
    "folke/tokyonight.nvim",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "tokyonight"
    end,
  },

  { "Shougo/goda.vim", lazy = false },

  {
    "Shougo/pum.vim",
    lazy = false,
    config = function()
      vim.fn["pum#set_option"] {
        auto_select = false,
        max_height = 10,
        max_width = 80,
        preview = true,
        preview_width = 80,
        previewer = "goda_cmp#get_previewer",
      }
    end,
  },

  {
    "Shougo/goda-cmp.vim",
    lazy = false,
    dependencies = { "Shougo/goda.vim", "Shougo/pum.vim" },
    config = function()
      vim.g["goda_cmp#config_dir"] = config_dir
      setup_keys()

      local group = vim.api.nvim_create_augroup("goda-cmp-dev", {})
      vim.api.nvim_create_autocmd("VimEnter", { group = group, once = true, callback = enable })
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = config_dir .. "/*.go",
        callback = function()
          vim.fn["goda_cmp#build"]()
          vim.notify("goda-cmp: ビルドして再起動しました", vim.log.levels.INFO)
        end,
      })
    end,
  },
}, {
  rocks = { enabled = false },
})
