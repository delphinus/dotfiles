local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

-- メイン nvim config の共有モジュール (jab.nvim のキー定義) を借りる。
package.path = vim.env.HOME .. "/.config/nvim/lua/?.lua;" .. package.path

-- 差分バッファのタブ幅。codediff は git リビジョン側 (codediff://) の filetype を
-- 意図的に空のままにし FileType autocmd も発火させないため、ftplugin/FileType では
-- 反映されない。左右両方で揃えるには global の tabstop を設定するのが確実。
vim.opt.tabstop = 4

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
    -- メイン config の clone をそのまま流用する。:CodeDiffWatch
    -- (lua/codediff_watch.lua) や下の共有モジュールは codediff の内部 API を
    -- 呼ぶので、メインとバージョンがずれると動かない。ビルド済みの
    -- libvscode_diff もメイン側の clone にある。
    "esmuellert/codediff.nvim",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/codediff.nvim",
    dependencies = { { "MunifTanjim/nui.nvim", dir = vim.fn.expand "~/.local/share/nvim/lazy/nui.nvim" } },
    cmd = { "CodeDiff" },
    -- codediff は diff タブに独自の q (タブを閉じる) を張るので無効化し、
    -- less のように「q でどこからでも nvim ごと終了」を global の q に任せる。
    opts = { keymaps = { view = { quit = false } } },
  },
  {
    -- メイン config の clone をそのまま流用する。差分は左右 2 ペインのどちらも
    -- 画面に収まらないことが多いので、位置が分かるバーを出す。
    "dstein64/nvim-scrollview",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/nvim-scrollview",
    lazy = false,
    init = function()
      -- signs_on_startup / on_startup は plugin/scrollview.vim が
      -- timer_start(0) で呼ぶ scrollview#Initialize() が読むだけなので、
      -- setup() ではなく init で vim.g に置く (メイン config と同じ事情)。
      -- codediff の nui パネル (ファイル一覧・履歴・キーヘルプ) は対象外。
      vim.g.scrollview_excluded_filetypes = { "codediff-explorer", "codediff-help", "codediff-history" }
      vim.g.scrollview_hide_on_float_intersect = true
      -- このサンドボックスには LSP も gitsigns も quickfix も無いので、
      -- 組み込みサインで意味があるのは検索とマークだけ。差分のサインは
      -- codediff_scrollview_signs が独自の群として登録する。
      vim.g.scrollview_signs_on_startup = { "marks", "search" }
      -- 1 行に複数グループのサインが重なると本文側へはみ出すので絞る。
      vim.g.scrollview_signs_max_per_row = 2
    end,
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
    -- メイン config の jab.nvim clone をそのまま流用する (別途クローンしない。
    -- skkeleton と同じ作法)。メインが今どのブランチを指していても追従するので、
    -- multi_window PR のマージ後もここは変更不要。
    "atusy/jab.nvim",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/jab.nvim",
    dependencies = { { "delphinus/luamigemo", dir = vim.fn.expand "~/.local/share/nvim/lazy/luamigemo" } },
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

-- 差分行に重なるコメントだけを明るくする (メイン config と共有。詳細は
-- lua/codediff_bright_comment.lua)。package.path でメイン config の lua/ を
-- 通してあるのでそのまま require できる。
require("codediff_bright_comment").setup()

-- 差分行の位置を nvim-scrollview のバーに出す (同じくメイン config と共有。
-- 詳細は lua/codediff_scrollview_signs.lua)。
require("codediff_scrollview_signs").setup()

-- 変更が無くても explorer を開いて待ち受ける :CodeDiffWatch (同じくメイン config と
-- 共有。詳細は lua/codediff_watch.lua)。kitty の codediff ペイン
-- (~/.config/kitty/codediff.py) がこれで起動する。
require("codediff_watch").setup()

-- jab.nvim はハイライトを設定できず、ラベル = Error・マッチ = CurSearch・
-- backdrop = Comment を固定で使う。flash 用の FlashMatch 設定は不要になった。

-- 既定の statusline には codediff:///<root>///<commit>/<path> という長いバッファ名が
-- そのまま出て、どのファイルなのか見分けにくい。比較元/比較先・リビジョン・
-- ファイル名だけを出す。ファイル名を先に置き、ディレクトリは後ろに薄く添える。
do
  local function define_hl()
    local removed = vim.api.nvim_get_hl(0, { name = "diffRemoved", link = false })
    local added = vim.api.nvim_get_hl(0, { name = "diffAdded", link = false })
    local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
    -- どのペインがアクティブかは要らないので、非アクティブ側もアクティブ側と同じ
    -- 色にする。ただし StatusLine と StatusLineNC の属性が完全に一致すると、
    -- カレントウィンドウの余白が '^' で埋められる。見た目に影響しない nocombine を
    -- 足して別の属性にしておく。
    local stl = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
    stl.nocombine = true
    vim.api.nvim_set_hl(0, "StatusLineNC", stl)
    -- 比較元/比較先のラベルは差分行と同じ赤/緑で塗る。それ以外は fg だけ指定し、
    -- 背景は StatusLine / StatusLineNC から引き継がせる。
    vim.api.nvim_set_hl(0, "CodeDiffStlOriginal", { fg = removed.fg, bg = removed.bg, bold = true })
    vim.api.nvim_set_hl(0, "CodeDiffStlModified", { fg = added.fg, bg = added.bg, bold = true })
    vim.api.nvim_set_hl(0, "CodeDiffStlFile", { bold = true })
    vim.api.nvim_set_hl(0, "CodeDiffStlDim", { fg = comment.fg })
  end
  define_hl()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = define_hl })

  local function escape(s)
    return (s:gsub("%%", "%%%%"))
  end

  -- nil は git 管理外のファイル同士の比較なので何も出さない。
  local function revision_label(rev)
    if rev == nil then
      return nil
    elseif rev == "WORKING" then
      return "作業ツリー"
    elseif rev == "STAGED" then
      return "ステージ"
    end
    local hash, parent = rev:match "^(%x+)(%^?)$"
    if hash and #hash > 7 then
      return hash:sub(1, 7) .. parent
    end
    return rev
  end

  local function relative_path(name, git_root)
    if vim.startswith(name, "codediff:///") then
      local _, _, filepath = require("codediff.core.virtual_file").parse_url(name)
      if filepath then
        return filepath
      end
    end
    if git_root and vim.startswith(name, git_root .. "/") then
      return name:sub(#git_root + 2)
    end
    return vim.fn.fnamemodify(name, ":~:.")
  end

  function _G.codediff_statusline()
    local win = vim.g.statusline_winid
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "codediff-explorer" then
      return " Files"
    elseif ft == "codediff-history" then
      return " History"
    end

    local lifecycle = package.loaded["codediff.ui.lifecycle"]
    local tab = vim.api.nvim_win_get_tabpage(win)
    local ctx = lifecycle and lifecycle.get_git_context(tab)
    local orig_win, mod_win = nil, nil
    if lifecycle then
      orig_win, mod_win = lifecycle.get_windows(tab)
    end

    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then
      return " [No Name]"
    end

    local parts = {}
    local rev
    if ctx and win == orig_win then
      table.insert(parts, "%#CodeDiffStlOriginal# 比較元 %*")
      rev = revision_label(ctx.original_revision)
    elseif ctx and win == mod_win then
      table.insert(parts, "%#CodeDiffStlModified# 比較先 %*")
      rev = revision_label(ctx.modified_revision)
    end
    -- explorer から開いた作業ツリー側は revision が nil のままなので、
    -- 実ファイルを開いていれば作業ツリーとみなす。
    if
      not rev
      and ctx
      and ctx.git_root
      and (win == orig_win or win == mod_win)
      and not vim.startswith(name, "codediff:///")
    then
      rev = "作業ツリー"
    end
    if rev then
      table.insert(parts, " " .. escape(rev) .. " ")
    end

    local path = relative_path(name, ctx and ctx.git_root)
    local tail = vim.fn.fnamemodify(path, ":t")
    local dir = vim.fn.fnamemodify(path, ":h")
    table.insert(parts, " %#CodeDiffStlFile#" .. escape(tail) .. "%*")
    if dir ~= "." then
      table.insert(parts, " %#CodeDiffStlDim#" .. escape(dir) .. "/%*")
    end
    table.insert(parts, " %m%r%=%l/%L ")
    return table.concat(parts)
  end

  vim.o.statusline = "%!v:lua.codediff_statusline()"
end
