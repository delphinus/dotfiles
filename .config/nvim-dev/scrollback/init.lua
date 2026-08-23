-- kitty の scrollback を Neovim で読むための最小構成。
-- ~/.config/kitty/keys.conf が NVIM_APPNAME=nvim-dev/scrollback で起動する。
--
-- 本体の設定 (~/.config/nvim) でも動くが、scrollback は「開いた瞬間に読んで拾って
-- 閉じる」ものなので、LSP・補完・各種 UI プラグインの autocmd を通したくない。
-- 欲しいのは配色と jab (migemo であいまいジャンプ) だけ。
--
-- WezTerm 時代の snatch.wezterm の置き換えとして試用中。snatch はタブ内の全ペインを
-- フロートで再現して jab の multi_window でまたいで飛べたが、こちらは単一ペイン。
-- 代わりに fork の維持もレイアウト再現も要らない。
--
-- プラグインは本体が入れたものを dir で共有する (nvim-dev の他の設定と同じ作法)。

local shared = vim.env.HOME .. "/.local/share/nvim/lazy"

local lazypath = shared .. "/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

-- メイン nvim config の共有モジュール (jab.nvim のキー定義) を借りる。
package.path = vim.env.HOME .. "/.config/nvim/lua/?.lua;" .. package.path

vim.opt.number = false
vim.opt.signcolumn = "no"
vim.opt.laststatus = 0
vim.opt.cmdheight = 0
vim.opt.swapfile = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"

require("lazy").setup({
  {
    "folke/tokyonight.nvim",
    dir = shared .. "/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "tokyonight-storm"
    end,
  },
  {
    -- 本体と同じく multi_window 対応の fork を使う。ここでは可視ウィンドウが
    -- 1 枚なので multi_window は効かないが、キー定義を共有するために揃えておく。
    "delphinus/jab.nvim",
    dir = shared .. "/jab.nvim",
    dependencies = { { "delphinus/luamigemo", dir = shared .. "/luamigemo" } },
    keys = require("jab_shared").keys,
  },
  {
    -- 起動そのものは kitty-scrollback.nvim の kitten が渡す --cmd が行う
    -- (rtp を足して User KittyScrollbackLaunch を発火する)。ここで lazy に
    -- 載せているのは setup() を通して設定を効かせるため。
    "mikesmithgh/kitty-scrollback.nvim",
    dir = shared .. "/kitty-scrollback.nvim",
    event = { "User KittyScrollbackLaunch" },
    config = function()
      require("kitty-scrollback").setup()
    end,
  },
}, {
  change_detection = { enabled = false },
  checker = { enabled = false },
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
