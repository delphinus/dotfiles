local shared = vim.env.HOME .. "/.local/share/nvim/lazy"

-- Borrow shared blink.cmp helpers / providers from the main nvim config so we
-- don't duplicate ~200 lines. The main config lives at ~/.config/nvim and
-- exposes blink_shared at lua/blink_shared.lua.
package.path = vim.env.HOME .. "/.config/nvim/lua/?.lua;" .. package.path
local blink_shared = require "blink_shared"

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end
vim.opt.cmdheight = 0

local find_sibling_pane, send_key_to_pane
if vim.env.EDITPROMPT then
  -- WezTerm にこのペインが editprompt であることを伝える
  io.write "\x1b]1337;SetUserVar=editprompt=MQ==\x07"
  function find_sibling_pane()
    local my_pane = vim.env.WEZTERM_PANE
    if not my_pane then
      return nil
    end
    local obj = vim.system({ "wezterm", "cli", "list", "--format", "json" }, { text = true }):wait()
    if obj.code ~= 0 then
      return nil
    end
    local ok, panes = pcall(vim.json.decode, obj.stdout)
    if not ok then
      return nil
    end
    local my_id = tonumber(my_pane)
    local my_tab
    for _, p in ipairs(panes) do
      if p.pane_id == my_id then
        my_tab = p.tab_id
        break
      end
    end
    if not my_tab then
      return nil
    end
    for _, p in ipairs(panes) do
      if p.tab_id == my_tab and p.pane_id ~= my_id then
        return tostring(p.pane_id)
      end
    end
    return nil
  end

  function send_key_to_pane(key)
    local target = find_sibling_pane()
    if not target then
      vim.notify("editprompt: could not find sibling pane", vim.log.levels.ERROR)
      return
    end
    vim.system({ "wezterm", "cli", "send-text", "--no-paste", "--pane-id", target, key }, { text = true })
  end
end

require("lazy").setup({
  { "nvim-lua/plenary.nvim", dir = shared .. "/plenary.nvim" },
  {
    "vim-denops/denops.vim",
    dir = shared .. "/denops.vim",
    init = function()
      vim.g["denops#server#deno_args"] = { "-q", "--no-lock", "--unstable-kv", "-A" }
    end,
  },

  {
    "vim-skk/skkeleton",
    dir = shared .. "/skkeleton",
    dependencies = {
      "vim-denops/denops.vim",
      { "delphinus/skkeleton_indicator.nvim", dir = shared .. "/skkeleton_indicator.nvim", opts = { fadeOutMs = 0 } },
    },
    lazy = false,
    keys = {
      -- Use these mappings in Karabiner-Elements
      { "<A-j>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" } },
      { "<A-J>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" } },
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
    },
    config = function()
      -- skkeleton#map sets a buffer-local <nowait> <CR> that shadows blink's
      -- global mapping. Re-override after enable to delegate to blink when
      -- its menu is visible.
      local cr_group = vim.api.nvim_create_augroup("skkeleton_blink_cr", {})
      vim.api.nvim_create_autocmd("User", {
        group = cr_group,
        pattern = "skkeleton-enable-post",
        callback = function()
          vim.keymap.set("i", "<CR>", function()
            local ok, blink = pcall(require, "blink.cmp")
            if ok and blink.is_visible() then
              blink.select_and_accept()
              return
            end
            vim.fn["skkeleton#handle"]("handleKey", { key = vim.keycode "<CR>" })
          end, { buffer = true, nowait = true, desc = "blink + skkeleton <CR>" })
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = cr_group,
        pattern = "skkeleton-disable-pre",
        callback = function()
          pcall(vim.keymap.del, "i", "<CR>", { buffer = true })
        end,
      })

      -- 補完候補の並び順学習 (getRanks) を永続化する。デフォルト ("") では
      -- denops プロセスのメモリ内にしか乗らず、再起動・別インスタンスで失われる。
      -- nvim / nvim-dev でランクを共有したいので stdpath ("state") (NVIM_APPNAME
      -- 依存) ではなく固定パスにする。Deno.writeTextFile は親ディレクトリを
      -- 作らないので Lua 側で先に掘っておく。
      local rank_file = vim.fs.normalize "~/.local/state/skkeleton/completion-rank.json"
      vim.fn.mkdir(vim.fs.dirname(rank_file), "p")

      -- blink-cmp-skkeleton の補完取得を診断するためのログ出力先 (skk_server の
      -- ソケット応答ズレ調査用)。補完が出なくなったら再起動せずにこのファイルを
      -- 確認する。原因特定後に削除予定。main nvim と別ファイルにして混線を防ぐ。
      vim.g.blink_cmp_skkeleton_debug_file = vim.fs.normalize "~/.local/state/skkeleton/blink-skk-debug-dev.log"

      vim.fn["skkeleton#config"] {
        userDictionary = vim.fs.normalize "~/git/github.com/delphinus/skk-jisyo/skk-jisyo.utf8",
        completionRankFile = rank_file,
        eggLikeNewline = true,
        immediatelyCancel = false,
        registerConvertResult = true,
        sources = { "skk_server" },
        -- yaskkserv2 を --midashi-utf8 で起動しているため、見出しも UTF-8 で送る。
        skkServerReqEnc = "utf-8",
        skkServerResEnc = "utf-8",
        databasePath = vim.fn.stdpath "data" .. "/skkeleton.db",
        -- markerHenkan = "󰇆",
        -- markerHenkanSelect = "󱨉",
        -- markerHenkan = "󰽤",
        -- markerHenkanSelect = "󰽢",
        -- markerHenkan = "󰜌",
        -- markerHenkanSelect = "󰜋",
        -- markerHenkan = "󰝣",
        -- markerHenkanSelect = "󰄮",
      }
      vim.fn["skkeleton#register_kanatable"]("rom", {
        ["("] = { "（", "" },
        [")"] = { "）", "" },
        ["z "] = { "　", "" },
        ["z1"] = { "①", "" },
        ["z2"] = { "②", "" },
        ["z3"] = { "③", "" },
        ["z4"] = { "④", "" },
        ["z5"] = { "⑤", "" },
        ["z6"] = { "⑥", "" },
        ["z7"] = { "⑦", "" },
        ["z8"] = { "⑧", "" },
        ["z9"] = { "⑨", "" },
        ["<s-q>"] = "henkanPoint",
      })
    end,
  },

  {
    "saghen/blink.cmp",
    dir = shared .. "/blink.cmp",
    dependencies = {
      -- 実体は主設定 (lua/lazies/skkeleton.lua) が feat/async-completion
      -- (Xantibody#19) で管理。ここは dir 共有で同じチェックアウトを使う。
      { "delphinus/blink-cmp-skkeleton", branch = "feat/async-completion", dir = shared .. "/blink-cmp-skkeleton" },
      { "delphinus/cmp-wezterm", dir = shared .. "/cmp-wezterm" },
      { "delphinus/cmp-ghq", dir = shared .. "/cmp-ghq" },
      { "mikavilpas/blink-ripgrep.nvim", dir = shared .. "/blink-ripgrep.nvim" },
      { "moyiz/blink-emoji.nvim", dir = shared .. "/blink-emoji.nvim" },
      { "Kaiser-Yang/blink-cmp-dictionary", dir = shared .. "/blink-cmp-dictionary" },
      { "delphinus/blink-cmp-digraphs", dir = shared .. "/blink-cmp-digraphs" },
      { "delphinus/blink-cmp-git", dir = shared .. "/blink-cmp-git" },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono" },
      completion = {
        accept = { create_undo_point = false },
        menu = {
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name", gap = 1 },
            },
            components = vim.tbl_extend("force", blink_shared.menu_components(), {
              label = {
                text = function(ctx)
                  if ctx.label_detail and ctx.label_detail ~= "" then
                    return ctx.label .. " " .. ctx.label_detail
                  end
                  return ctx.label
                end,
                highlight = function(ctx)
                  return blink_shared.with_skk_label_match(ctx, function(c)
                    local label = c.label
                    local highlights = {
                      { 0, #label, group = c.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel" },
                    }
                    if c.label_detail and c.label_detail ~= "" then
                      table.insert(
                        highlights,
                        { #label + 1, #label + 1 + #c.label_detail, group = "BlinkCmpLabelDetail" }
                      )
                    end
                    for _, idx in ipairs(c.label_matched_indices) do
                      table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                    end
                    return highlights
                  end)
                end,
              },
            }),
          },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        default = function()
          local ok, skk = pcall(require, "blink-cmp-skkeleton")
          if ok and skk.is_enabled() then
            return { "skkeleton" }
          end
          if blink_shared.in_path_context() then
            return { "path" }
          end
          return { "buffer", "path", "wezterm", "ghq", "digraphs", "git", "ripgrep", "dictionary", "emoji" }
        end,
        providers = vim.tbl_extend("force", blink_shared.providers(), {
          path = { opts = { show_hidden_files_by_default = true } },
        }),
      },
      fuzzy = {
        -- skkeleton ON 時のみ data.rank で Lua sort、OFF 時は文字列 sort のみで
        -- blink の Rust sort 最適化を効かせる。詳細は blink_shared.fuzzy_sorts。
        sorts = blink_shared.fuzzy_sorts,
      },
      keymap = {
        preset = "default",
        ["<CR>"] = { "select_and_accept", "fallback" },
        -- macOS の IME 切り替えと被るため `<C-Space>` 代わりの手動トリガー。
        ["<C-,>"] = { "show", "fallback" },
        ["<C-n>"] = {
          function(cmp)
            if cmp.is_visible() then
              cmp.select_next()
              return true
            elseif send_key_to_pane then
              send_key_to_pane "\x1b[B"
              return true
            end
          end,
          "fallback",
        },
        ["<C-p>"] = {
          function(cmp)
            if cmp.is_visible() then
              cmp.select_prev()
              return true
            elseif send_key_to_pane then
              send_key_to_pane "\x1b[A"
              return true
            end
          end,
          "fallback",
        },
        ["<A-u>"] = { "scroll_documentation_up", "fallback" },
        ["<A-d>"] = { "scroll_documentation_down", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<Space>"] = {}, -- let skkeleton handle Space
      },
      cmdline = {
        completion = {
          menu = { auto_show = true },
          list = { selection = { preselect = false, auto_insert = true } },
        },
      },
    },
  },

  {
    "delphinus/luamigemo",
    dir = shared .. "/luamigemo",
  },

  {
    "delphinus/cellwidths.nvim",
    dir = shared .. "/cellwidths.nvim",
    config = function()
      vim.opt.listchars = {
        tab = "▓░",
        trail = "↔",
        eol = "⏎",
        extends = "‥",
        precedes = "←",
        nbsp = "␣",
      }
      vim.opt.fillchars = {
        diff = "░",
        eob = "‣",
        fold = "░",
        foldopen = "▾",
        foldsep = "│",
        foldclose = "▸",
      }
      require("cellwidths").setup {
        name = "user/custom",
        fallback = function(cw)
          cw.load "sfmono_square"
          cw.add { 0xf0000, 0x10ffff, 2 }
          return cw
        end,
      }
    end,
  },

  {
    "m00qek/baleia.nvim",
    dir = shared .. "/baleia.nvim",
    cmd = { "BaleiaColorize", "BaleiaColorizeStartup" },
    config = function()
      local baleia
      vim.api.nvim_create_user_command("BaleiaColorize", function()
        if not baleia then
          baleia = require("baleia").setup {}
        end
        baleia.once(vim.api.nvim_get_current_buf())
      end, {})
      vim.api.nvim_create_user_command("BaleiaColorizeStartup", function()
        vim.api.nvim_create_autocmd("VimEnter", { command = "BaleiaColorize" })
      end, {})
    end,
  },

  {
    "rhysd/committia.vim",
    dir = shared .. "/committia.vim",
    ft = { "gitcommit" },
    init = function()
      vim.g.committia_hooks = {
        ---@class CommittiaInfo
        ---@field vcs string vcs type (e.g. 'git')
        ---@field edit_winnr integer winnr of edit window
        ---@field edit_bufnr integer bufnr of edit window
        ---@field diff_winnr integer winnr of diff window
        ---@field diff_bufnr integer bufnr of diff window
        ---@field status_winnr integer winnr of status window
        ---@field status_bufnr integer bufnr of status window

        ---@param info CommittiaInfo
        edit_open = function(info)
          vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
            once = true,
            pattern = { "COMMIT_EDITMSG", "MERGE_MSG" },
            callback = function()
              local winid = vim.fn.win_getid(info.edit_winnr)
              -- HACK: move cursor to top left because it starts on the 2nd line for some reason.
              vim.api.nvim_win_set_cursor(winid, { 1, 0 })
              local first_line = vim.api.nvim_buf_get_lines(info.edit_bufnr, 0, 1, false)[1]
              if first_line == "" then
                vim.cmd.startinsert()
              end
            end,
          })
          vim.keymap.set("i", "<A-D>", [[<Plug>(committia-scroll-diff-down-half)]], { buffer = true })
          vim.keymap.set("i", "<A-U>", [[<Plug>(committia-scroll-diff-up-half)]], { buffer = true })
        end,
      }
    end,
    config = function()
      local bufname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
      if bufname == "COMMIT_EDITMSG" or bufname == "MERGE_MSG" then
        vim.fn["committia#open"] "git"
      end
    end,
  },

  {
    "folke/flash.nvim",
    dir = shared .. "/flash.nvim",
    keys = {
      {
        "s",
        function()
          require("flash").jump()
        end,
        mode = { "n", "x" },
        desc = "Flash (migemo)",
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

  -- tokyonight (local clone shared with main config)
  {
    "folke/tokyonight.nvim",
    dir = shared .. "/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
}, { lazy = false })

vim.cmd.colorscheme "tokyonight"

blink_shared.setup_profiler()

if vim.env.EDITPROMPT then
  -- 兄弟ペイン (Claude Code) の画面テキストから番号付き選択肢を検出する。
  -- 行頭が空白・枠線・❯ 等の非英数字のみ、続けて "N. label" のものを拾い、
  -- 番号 → ラベルの表と、現在強調中 (❯) の番号を返す。散文 (例: "Step 1.") は弾く。
  local function detect_menu(text)
    local labels, highlighted = {}, nil
    for line in text:gmatch "[^\n]+" do
      local pre, n, label = line:match "^([^%w]-)(%d+)%.%s(.*)$"
      if n then
        n = tonumber(n)
        label = label:gsub("%s*│%s*$", ""):gsub("%s+$", "")
        labels[n] = label
        if pre:find("❯", 1, true) then
          highlighted = n
        end
      end
    end
    return labels, highlighted
  end

  -- 確定した選択肢を ccstatusline 用のキャッシュへ書く。キーは対象 (Claude Code)
  -- ペインの id。ccstatusline は $WEZTERM_PANE でここを読みステータスラインに出す。
  local confirm_dir = vim.env.HOME .. "/.cache/ccstatusline-smart-confirm"
  local function write_selection(target, chosen, label)
    pcall(function()
      vim.fn.mkdir(confirm_dir, "p")
      local f = io.open(confirm_dir .. "/" .. target, "w")
      if f then
        f:write(string.format("%d\t%d. %s", os.time(), chosen, label or ""))
        f:close()
      end
    end)
  end

  local function editprompt_send()
    vim.cmd "stopinsert"
    vim.cmd "update"
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local content = table.concat(lines, "\n")
    if content == "" then
      -- バッファが空 = メッセージ送信ではなくメニュー確定。兄弟ペイン (Claude Code)
      -- の選択肢を読み、3 択以上なら ↓ で真ん中 (option 2) を選んでから Enter する。
      local target = find_sibling_pane()
      if not target then
        vim.notify("editprompt: could not find sibling pane", vim.log.levels.ERROR)
        return
      end
      local keys = "\r"
      local obj = vim.system({ "wezterm", "cli", "get-text", "--pane-id", target }, { text = true }):wait()
      if obj.code == 0 and obj.stdout then
        local labels, highlighted = detect_menu(obj.stdout)
        -- 1. と 2. が揃っていれば選択メニューとみなす。
        if labels[1] and labels[2] then
          local chosen
          if labels[3] then
            -- 3 択以上: ↓ を送って option 2 を確定。
            chosen = 2
            keys = "\x1b[B\r" -- ↓ then Enter
          else
            -- 2 択: いま強調されている選択肢 (無ければ option 1) をそのまま確定。
            chosen = highlighted or 1
          end
          write_selection(target, chosen, labels[chosen])
        end
      end
      vim.system({ "wezterm", "cli", "send-text", "--no-paste", "--pane-id", target, keys }, { text = true }, function()
        vim.schedule(function()
          vim.cmd "startinsert"
        end)
      end)
      return
    end
    -- @ で終わる場合はスペースを付ける（editprompt の processContent と同じ）
    if content:match "@[^\n]*$" then
      content = content .. " "
    end
    local target = find_sibling_pane()
    if not target then
      vim.notify("editprompt: could not find sibling pane", vim.log.levels.ERROR)
      return
    end
    -- send-text でテキストを送信し、続けて Enter を送る
    vim.system(
      { "wezterm", "cli", "send-text", "--no-paste", "--pane-id", target, "--", content },
      { text = true },
      function(obj)
        if obj.code ~= 0 then
          vim.schedule(function()
            vim.notify("editprompt failed: " .. (obj.stderr or "unknown error"), vim.log.levels.ERROR)
          end)
          return
        end
        -- Enter キーを送る
        vim.system(
          { "wezterm", "cli", "send-text", "--no-paste", "--pane-id", target, "\r" },
          { text = true },
          function(obj2)
            vim.schedule(function()
              if obj2.code == 0 then
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
                vim.cmd "silent write"
                vim.cmd "startinsert"
              else
                vim.notify(
                  "editprompt failed to send Enter: " .. (obj2.stderr or "unknown error"),
                  vim.log.levels.ERROR
                )
              end
            end)
          end
        )
      end
    )
  end

  vim.keymap.set("n", "<Space>x", editprompt_send, { silent = true, desc = "Send buffer content to editprompt" })
  vim.keymap.set("i", "<C-CR>", editprompt_send, { silent = true, desc = "Send buffer content to editprompt" })
  vim.keymap.set("i", "<D-CR>", editprompt_send, { silent = true, desc = "Send buffer content to editprompt" })
  vim.keymap.set("i", "<S-CR>", editprompt_send, { silent = true, desc = "Send buffer content to editprompt" })
  -- HHKB の Fn+Enter は WezTerm が keypad-enter (kitty PUA 57414) として送るので
  -- <kEnter> になる。<C-CR> と同じ確定用途に割り当てる。
  vim.keymap.set(
    "i",
    "<kEnter>",
    editprompt_send,
    { silent = true, desc = "Send buffer content to editprompt (HHKB Fn+Enter)" }
  )
  local function forward_when_empty(lhs, raw_key)
    vim.keymap.set("i", lhs, function()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      if table.concat(lines, "\n") == "" then
        send_key_to_pane(raw_key)
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, false, true), "n", false)
      end
    end, { silent = true, desc = "Send " .. lhs .. " to sibling pane when buffer is empty" })
  end
  forward_when_empty("<C-u>", "\x15")
  forward_when_empty("<Up>", "\x1b[A")
  forward_when_empty("<Down>", "\x1b[B")
end
