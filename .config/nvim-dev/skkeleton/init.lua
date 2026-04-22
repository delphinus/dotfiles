local shared = vim.env.HOME .. "/.local/share/nvim/lazy"

-- Shim missing nvim-cmp internals so blink.compat-loaded cmp sources
-- (cmp-look, cmp-wezterm) don't blow up on top-level requires.
package.preload["cmp.utils.debug"] = function()
  return { log = function() end, flag = false }
end

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

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

      vim.fn["skkeleton#config"] {
        userDictionary = vim.fs.normalize "~/Documents/skk-jisyo.utf8",
        eggLikeNewline = true,
        immediatelyCancel = false,
        registerConvertResult = true,
        sources = { "skk_server" },
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
      { "saghen/blink.compat", dir = shared .. "/blink.compat", opts = {} },
      { "Xantibody/blink-cmp-skkeleton", dir = shared .. "/blink-cmp-skkeleton" },
      { "delphinus/cmp-wezterm", dir = shared .. "/cmp-wezterm" },
      { "hrsh7th/cmp-emoji", dir = shared .. "/cmp-emoji" },
      { "lukas-reineke/cmp-rg", dir = shared .. "/cmp-rg" },
      { "octaltree/cmp-look", dir = shared .. "/cmp-look" },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono" },
      completion = {
        menu = {
          draw = {
            components = {
              label = {
                text = function(ctx)
                  if ctx.label_detail and ctx.label_detail ~= "" then
                    return ctx.label .. " " .. ctx.label_detail
                  end
                  return ctx.label
                end,
                highlight = function(ctx)
                  local label = ctx.label
                  local highlights = {
                    { 0, #label, group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel" },
                  }
                  if ctx.label_detail and ctx.label_detail ~= "" then
                    table.insert(
                      highlights,
                      { #label + 1, #label + 1 + #ctx.label_detail, group = "BlinkCmpLabelDetail" }
                    )
                  end
                  for _, idx in ipairs(ctx.label_matched_indices) do
                    table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                  end
                  return highlights
                end,
              },
            },
          },
        },
      },
      sources = {
        default = function()
          local ok, skk = pcall(require, "blink-cmp-skkeleton")
          if ok and skk.is_enabled() then
            return { "skkeleton" }
          end
          return { "wezterm", "path", "rg", "emoji", "look" }
        end,
        providers = {
          path = { opts = { show_hidden_files_by_default = true } },
          wezterm = { name = "wezterm", module = "blink.compat.source", min_keyword_length = 2 },
          rg = { name = "rg", module = "blink.compat.source", min_keyword_length = 4 },
          emoji = { name = "emoji", module = "blink.compat.source" },
          look = {
            name = "look",
            module = "blink.compat.source",
            min_keyword_length = 4,
            opts = { convert_case = true, loud = true },
          },
          skkeleton = { name = "skkeleton", module = "blink-cmp-skkeleton" },
        },
      },
      keymap = {
        preset = "default",
        ["<CR>"] = { "select_and_accept", "fallback" },
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
}, { lazy = false })

vim.cmd.colorscheme "catppuccin"

if vim.env.EDITPROMPT then
  local function editprompt_send()
    vim.cmd "stopinsert"
    vim.cmd "update"
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local content = table.concat(lines, "\n")
    if content == "" then
      local target = find_sibling_pane()
      if not target then
        vim.notify("editprompt: could not find sibling pane", vim.log.levels.ERROR)
        return
      end
      vim.system({ "wezterm", "cli", "send-text", "--no-paste", "--pane-id", target, "\r" }, { text = true }, function()
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
