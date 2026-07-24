local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

-- メイン nvim config の共有モジュール (jab.nvim のキー定義) を借りる。
package.path = vim.env.HOME .. "/.config/nvim/lua/?.lua;" .. package.path

-- less のようにノーマルモードの q で終了する (未保存でも破棄して終了)
vim.keymap.set("n", "q", "<Cmd>quitall!<CR>")

-- <C-d>/<C-u> は 3 行ずつスクロールする
vim.keymap.set({ "n", "v" }, "<C-d>", "3<C-d>")
vim.keymap.set({ "n", "v" }, "<C-u>", "3<C-u>")

-- ウィンドウ間を移動する
vim.keymap.set("n", "<C-j>", "<C-w>w")
vim.keymap.set("n", "<C-k>", "<C-w>W")

require("lazy").setup {
  {
    "folke/tokyonight.nvim",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = { "CodeDiff" },
    -- codediff は diff タブに独自の q (タブを閉じる) を張るので無効化し、
    -- less のように「q でどこからでも nvim ごと終了」を global の q に任せる。
    opts = { keymaps = { view = { quit = false } } },
  },
  {
    -- メイン config が使う nvim-treesitter (main ブランチ) をそのまま流用する。
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/nvim-treesitter",
    lazy = false,
    config = function()
      -- parser (parser/*.so) と query (queries/) はメイン nvim の install_dir
      -- (~/.local/share/nvim/site) に既にあるので、そこを指すだけで再利用できる。
      require("nvim-treesitter").setup {
        install_dir = vim.fn.expand "~/.local/share/nvim/site",
      }
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", {}),
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
  {
    "atusy/jab.nvim",
    dependencies = { { "delphinus/luamigemo", version = "*" } },
    -- キー定義はメイン config と共有 (lua/jab_shared.lua)。以下の flash 専用機能は
    -- jab に無いため移行できず、下の enabled = false の flash ブロックに残す:
    --   S     treesitter()          treesitter ノードを選択
    --   r     remote() (o)          オペレータ待機中のリモート操作
    --   R     treesitter_search()   treesitter 検索
    --   <C-s> toggle() (c)          コマンドライン検索中のラベル表示の切り替え
    keys = require("jab_shared").keys,
  },

  -- 移行前の flash.nvim 設定。enabled = false で無効化しつつ参考に残す
  -- (S/r/R/<C-s> は jab に無い機能)。
  {
    enabled = false,
    -- メイン config と同じくフォーク版を使用 (長大な migemo 正規表現で
    -- labeler:skip() が遅くなる問題を回避するパッチを含む)。
    "delphinus/flash.nvim",
    branch = "fix/skip-label-filtering-for-long-patterns",
    dependencies = { { "delphinus/luamigemo", version = "*" } },
    keys = {
      {
        "s",
        function()
          require("flash").jump()
        end,
        mode = { "n", "x", "o" },
        desc = "Flash (migemo)",
      },
      {
        "S",
        function()
          require("flash").treesitter()
        end,
        mode = { "n", "x", "o" },
        desc = "Flash Treesitter",
      },
      {
        "r",
        function()
          require("flash").remote()
        end,
        mode = "o",
        desc = "Remote Flash",
      },
      {
        "R",
        function()
          require("flash").treesitter_search()
        end,
        mode = { "o", "x" },
        desc = "Treesitter Search",
      },
      {
        "<C-s>",
        function()
          require("flash").toggle()
        end,
        mode = "c",
        desc = "Toggle Flash Search",
      },
    },
    opts = {
      labels = "HJKLASDFGYUIOPQWERTNMZXCVB",
      search = {
        mode = function(str)
          if str == "" then
            return str
          elseif #str < 2 then
            return [[\c]] .. str .. [[\|\%#.]]
          end
          local migemo = require "luamigemo"
          return [[\c]] .. migemo.query(str, migemo.RXOP_VIM)
        end,
      },
    },
  },
}

vim.cmd.colorscheme "tokyonight"

-- jab.nvim はハイライトを設定できず、ラベル = Error・マッチ = CurSearch・
-- backdrop = Comment を固定で使う。flash 用の FlashMatch 設定は不要になった。
