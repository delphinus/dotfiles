-- kitty の scrollback を Neovim で読むための最小構成。
-- ~/.config/kitty/keys.conf が NVIM_APPNAME=nvim-dev/scrollback で起動する。
--
-- 本体の設定 (~/.config/nvim) でも動くが、scrollback は「開いたらすぐ読んで拾って
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

-- 'background' を明示して端末の背景色からの推測を止める。下の paint_frame が
-- overlay の既定背景色を明るい橙に変えると、kitty が mode 2031 で色の変化を
-- 知らせ、nvim は OSC 11 を問い直して 'background' を light に切り替える
-- (nvim 0.13-dev で OSC 11 のハンドラが起動後も残るようになった)。tokyonight
-- はそれを受けて day に変わってしまう。colorscheme 側が vim.o で入れた値は
-- 「ユーザの設定」と見なされず上書きされるので、init.lua で入れる必要がある。
vim.o.background = "dark"

-- ヤンクの既定を「クリップボードに入れて kitty に戻る」にする。
--
-- kitty-scrollback.nvim は TextYankPost を見ていて、"+ へのヤンクなら quitall、
-- paste_window.yank_register (既定は無名レジスタ) へのヤンクならペースト
-- ウィンドウを開く。つまり素の y は「クリップボードに入る (clipboard=unnamedplus)
-- が、ペーストウィンドウも開いて閉じるまで戻れない」になっていた。拾って閉じる
-- のが大半なので、素の y はクリップボードに入れてそのまま kitty へ戻す。
--
-- 編集してから kitty に送りたいときだけ gy でオプトインする。
--
-- どちらも行頭の共通インデントを除いてから渡す。Claude Code の画面は左に 2 桁
-- の余白があり、そのまま拾うと貼り付け先で邪魔になる。プラグインの TextYankPost
-- はヤンクした内容 (v:event.regcontents) をそのまま使い、書き換える口が無いので、
-- y は "c、gy は "p へヤンクさせてプラグインの判定 ("+ と yank_register) から
-- 外し、下の TextYankPost で整形してからクリップボード / ペーストウィンドウへ
-- 送る。yank_register_enabled は setup() で切ってある。
--
-- マッピングは scrollback バッファ限定 (buffer local)。ペーストウィンドウの中で
-- y を押したら quitall する、という間違いを避ける。
local REG_CLIPBOARD = "c"
local REG_PASTE = "p"

-- 空白だけの行を除いた各行の、行頭の空白の最小値だけ全行から削る。
-- 文字単位のヤンクを行の途中から始めた場合、1 行目は字下げを含まないので
-- 最小値の計算から外す (含めると常に 0 になって何も削れない)。
local function dedent(lines, regtype)
  local first = 1
  if regtype == "v" and vim.fn.col "'[" > 1 then
    first = 2
  end
  local min
  for i = first, #lines do
    local line = lines[i]
    if line:find "%S" then
      local indent = #line:match "^%s*"
      if not min or indent < min then
        min = indent
      end
    end
  end
  if not min or min == 0 then
    return lines
  end
  return vim.tbl_map(function(line)
    return line:sub(math.min(#line:match "^%s*", min) + 1)
  end, lines)
end

-- プラグインが "p (yank_register) へのヤンクで行っていた処理と同じ。行末の空白を
-- 削り、ペーストウィンドウの最後の空でない行の後ろに空行を挟んで足す。
local function send_to_paste_window(lines)
  lines = vim.tbl_map(function(line)
    return (line:gsub("%s+$", ""))
  end, lines)
  require("kitty-scrollback.windows").open_paste_window()
  local bufnr = vim.iter(vim.api.nvim_list_bufs()):find(function(b)
    return vim.api.nvim_buf_get_name(b):match "%.ksb_pastebuf$" ~= nil
  end)
  if not bufnr then
    return
  end
  local current = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local lastline = 0
  for i = #current, 1, -1 do
    if current[i]:find "%S" then
      lastline = i
      break
    end
  end
  if lastline > 0 then
    table.insert(lines, 1, "")
  end
  vim.api.nvim_buf_set_lines(bufnr, lastline, lastline, false, lines)
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ScrollbackYank", {}),
  pattern = "kitty-scrollback",
  callback = function(ev)
    local function map(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf })
    end
    map({ "n", "x" }, "y", '"' .. REG_CLIPBOARD .. "y")
    map({ "n", "x" }, "gy", '"' .. REG_PASTE .. "y")
    -- Y は Neovim の既定 (n: y$ / x: linewise) に合わせる。
    map("n", "Y", '"' .. REG_CLIPBOARD .. "y$")
    map("x", "Y", '"' .. REG_CLIPBOARD .. "Y")
    map("n", "gY", '"' .. REG_PASTE .. "y$")
    map("x", "gY", '"' .. REG_PASTE .. "Y")

    vim.api.nvim_create_autocmd("TextYankPost", {
      group = vim.api.nvim_create_augroup("ScrollbackYankDedent", {}),
      buffer = ev.buf,
      callback = function()
        local event = vim.v.event
        if event.operator ~= "y" then
          return
        end
        local lines = dedent(event.regcontents, event.regtype)
        if event.regname == REG_CLIPBOARD then
          vim.fn.setreg("+", lines, event.regtype)
          -- プラグインの close_after_yank と同じく、次のループで閉じる。
          vim.defer_fn(require("kitty-scrollback.util").quitall, 0)
        elseif event.regname == REG_PASTE then
          vim.schedule(function()
            send_to_paste_window(lines)
          end)
        end
      end,
    })
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
-- ただしこれが見えるのは、タブに見えているペインが 1 つのときだけ。複数あると
-- kitty は帯をウィンドウではなく kitty 全体の既定背景色で塗るので、橙にならない。
-- そのときは代わりに本文の背景 (KittyScrollbackNvimNormal) に橙を薄く混ぜる。
-- stack レイアウト (⌘⇧Z のズーム) は他のペインが隠れているので 1 つと数える。
--
-- 塗るのは kitten が作った overlay ウィンドウ (KITTY_WINDOW_ID) だけ。nvim を
-- 閉じると overlay ごと消えるので、色を戻す後始末は要らない。kitty_data の
-- window_id は scrollback 元のウィンドウなので、こちらを塗ってはいけない。
local FRAME_COLOR = "#ff9e64" -- tokyonight-storm の orange
local TINT_ALPHA = 0.12

local function tint_background()
  local normal = vim.api.nvim_get_hl(0, { name = "KittyScrollbackNvimNormal", link = false })
  if not normal.bg then
    return
  end
  local bg = require("kitty-scrollback.util").blend(FRAME_COLOR, ("#%06x"):format(normal.bg), TINT_ALPHA)
  -- プラグインは default = true で定義するので、ColorScheme で定義し直されても
  -- ここで入れた値は上書きされない。
  vim.api.nvim_set_hl(0, "KittyScrollbackNvimNormal", { fg = normal.fg, bg = bg })
end

local function paint_frame(kitty_data)
  local window_id = vim.env.KITTY_WINDOW_ID
  if not window_id then
    return
  end
  local kitty = kitty_data.kitty_path
  local match = "--match=id:" .. window_id
  -- 飾りなので失敗しても何も言わずに進む (remote control が無い環境でも困らない)。
  pcall(vim.system, { kitty, "@", "ls", match }, { text = true }, function(ls)
    local ok, data = pcall(vim.json.decode, ls.stdout or "")
    local tab = ok and vim.tbl_get(data, 1, "tabs", 1)
    if not tab then
      return
    end
    if tab.layout == "stack" or #tab.groups <= 1 then
      pcall(vim.system, { kitty, "@", "set-colors", match, "background=" .. FRAME_COLOR })
    else
      vim.schedule(tint_background)
    end
  end)
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
    -- 1 枚なので multi_window は無意味だが、キー定義を共有するために揃えておく。
    "delphinus/jab.nvim",
    dir = shared .. "/jab.nvim",
    dependencies = { { "delphinus/luamigemo", dir = shared .. "/luamigemo" } },
    keys = require("jab_shared").keys,
  },
  {
    -- 起動そのものは kitty-scrollback.nvim の kitten が渡す --cmd が行う
    -- (rtp を足して User KittyScrollbackLaunch を発火する)。ここで lazy に
    -- 載せているのは setup() を通して設定を渡すため。
    "mikesmithgh/kitty-scrollback.nvim",
    dir = shared .. "/kitty-scrollback.nvim",
    event = { "User KittyScrollbackLaunch" },
    config = function()
      -- 起動を速くするための間引き。⌘[ から本文が出るまでを測ると (scrollback
      -- 2081 行) 282ms 掛かっていて、内訳は プロセス起動 66 / nvim の
      -- 設定 19 / kitty @ get-colors 27 / ローディング窓の開閉 67 / 本文の
      -- 流し込み 72 / kitty @ signal-child 27 (単位 ms)。kitty への remote
      -- control は 1 往復 25-40ms 掛かるので、要らない往復を落とすのが一番速い。
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
      -- 適用される。素の opts を渡しても読まれない。関数を置くと kitty から
      -- 渡ってきた kitty_data を見て opts を組み立てられる。
      require("kitty-scrollback").setup {
        function(kitty_data)
          -- 本文を流し込む端末バッファの桁数。既定は 300 で、一時的にそこまで
          -- columns を広げてから戻す、というもの。長い行が窓幅で折り返されるのを
          -- 防ぐためにあるが、scrollback は元の窓の幅で折り返された状態で入って
          -- いるので、元の窓より広げても得るものが無い。広げると columns の変更と
          -- 復帰で全画面の再描画が 2 回起きる。
          local columns = kitty_data.columns
          if vim.o.columns >= columns then
            -- columns を触らずに済むなら、その後始末として nvim 自身へ SIGWINCH
            -- を送る RC 往復 (27ms) も要らない。逆に (窓が縮んでいる等で) 広げる
            -- ことになった場合は、後始末が要るのでそのまま残す。
            ksb_cmds.signal_winchanged_to_kitty_child_process = function() end
          end
          return {
            paste_window = {
              -- 既定は無名レジスタへのヤンクでペーストウィンドウが開く。上の
              -- TextYankPost が gy から開くので、プラグイン側では開かせない。
              yank_register_enabled = false,
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
