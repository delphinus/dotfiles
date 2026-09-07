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

-- ヤンクの既定を「クリップボードに入れて kitty に戻る」にする。
--
-- kitty-scrollback.nvim は TextYankPost を見ていて、"+ へのヤンクなら quitall、
-- paste_window.yank_register (既定は無名レジスタ) へのヤンクならペースト
-- ウィンドウを開く。つまり素の y は「クリップボードに入る (clipboard=unnamedplus)
-- が、ペーストウィンドウも開いて閉じるまで戻れない」になっていた。拾って閉じる
-- のが大半なので、素の y を "+y にしてそのまま kitty へ戻す。
--
-- 編集してから kitty に送りたいときだけ gy でオプトインする。ペースト
-- ウィンドウ用のレジスタを無名から "p へ移してあるので、y と衝突しない。
--
-- マッピングは scrollback バッファ限定 (buffer local)。ペーストウィンドウの中で
-- y を押したら quitall する、という事故を避ける。
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ScrollbackYank", {}),
  pattern = "kitty-scrollback",
  callback = function(ev)
    local function map(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf })
    end
    map({ "n", "x" }, "y", '"+y')
    map({ "n", "x" }, "gy", '"py')
    -- Y は Neovim の既定 (n: y$ / x: linewise) に合わせる。
    map("n", "Y", '"+y$')
    map("x", "Y", '"+Y')
    map("n", "gY", '"py$')
    map("x", "gY", '"pY')
  end,
})

-- scrollback を開いていることを「窓の枠の色」で示す (WezTerm 時代の snatch が
-- ターミナルの枠を塗っていたのと同じ発想)。
--
-- kitty は window_padding_width の帯 (kitty.conf で 8px) を「そのウィンドウの
-- 既定背景色」で塗る。nvim は全セルに Normal の背景を明示的に敷くので、既定
-- 背景色だけ差し替えれば本文の見た目は一切変わらず、周囲 8px だけが色付く。
-- 今は既定背景色が tokyonight-storm の背景 (#24283b) と同じなので枠が見えない。
--
-- 塗るのは kitten が作った overlay ウィンドウ (KITTY_WINDOW_ID) だけ。nvim を
-- 閉じると overlay ごと消えるので、色を戻す後始末は要らない。kitty_data の
-- window_id は scrollback 元のウィンドウなので、こちらを塗ってはいけない。
local FRAME_COLOR = "#ff9e64" -- tokyonight-storm の orange

local function paint_frame(kitty_data)
  local window_id = vim.env.KITTY_WINDOW_ID
  if not window_id then
    return
  end
  -- 飾りなので失敗しても黙って進む (remote control が無い環境でも壊さない)。
  pcall(vim.system, {
    kitty_data.kitty_path,
    "@",
    "set-colors",
    "--match=id:" .. window_id,
    "background=" .. FRAME_COLOR,
  })
end

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
      -- 起動を速くするための間引き。⌘[ から本文が出るまでを実測 (scrollback
      -- 2081 行) すると 282ms 掛かっていて、内訳は プロセス起動 66 / nvim の
      -- 設定 19 / kitty @ get-colors 27 / ローディング窓の開閉 67 / 本文の
      -- 流し込み 72 / kitty @ signal-child 27 (単位 ms)。kitty への remote
      -- control は 1 往復 25-40ms 掛かるので、要らない往復を落とすのが一番効く。
      -- 下の 2 つで 209ms になった。
      --
      -- get-colors は端末バッファの ANSI パレット (terminal_color_N) と選択範囲
      -- の色に要るので落とせない。
      local ksb_cmds = require "kitty-scrollback.kitty_commands"

      -- ローディング窓。kitty @ launch で python3 のスピナーを別ウィンドウとして
      -- 開き、読み込み後に kitty @ close-window で閉じる。⌘[ の直後に画面が暗く
      -- なるのはこれで、RC 2 往復 + python3 の起動に 67ms 掛かる上、その間は
      -- nvim の画面 (枠の色も) が隠れる。読み込み自体が 100ms ほどしか無いので、
      -- 隠さずそのまま見せる。
      ksb_cmds.open_kitty_loading_window = function() end

      -- setup() が取るのは「名前付き config の表」で、index 1 だけが特別扱いで
      -- 全 config (keys.conf が --config で指定する ksb_builtin_* も含む) に
      -- 適用される。素の opts を渡しても効かない。関数を置くと kitty から
      -- 渡ってきた kitty_data を見て opts を組み立てられる。
      require("kitty-scrollback").setup {
        function(kitty_data)
          -- 本文を流し込む端末バッファの桁数。既定は 300 で、一時的にそこまで
          -- columns を広げてから戻す、というもの。長い行が窓幅で折り返されるのを
          -- 防ぐためにあるが、scrollback は元の窓の幅で折り返された状態で入って
          -- いるので、元の窓より広げても得るものが無い。広げると columns の変更と
          -- 復帰で全画面の再描画が 2 回走る。
          local columns = kitty_data.columns
          if vim.o.columns >= columns then
            -- columns を触らずに済むなら、その後始末として nvim 自身へ SIGWINCH
            -- を送る RC 往復 (27ms) も要らない。逆に (窓が縮んでいる等で) 広げる
            -- ことになった場合は、後始末が要るのでそのまま残す。
            ksb_cmds.signal_winchanged_to_kitty_child_process = function() end
          end
          return {
            paste_window = {
              -- 既定は無名レジスタ = 素の y でペーストウィンドウが開く。上の
              -- FileType autocmd の gy (= "py) からだけ開くように移す。
              yank_register = "p",
            },
            callbacks = { after_setup = paint_frame },
            scrollback_columns = columns,
          }
        end,
      }
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
