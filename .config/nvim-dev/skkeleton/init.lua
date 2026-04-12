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
    if not my_pane then return nil end
    local obj = vim.system(
      { "wezterm", "cli", "list", "--format", "json" },
      { text = true }
    ):wait()
    if obj.code ~= 0 then return nil end
    local ok, panes = pcall(vim.json.decode, obj.stdout)
    if not ok then return nil end
    local my_id = tonumber(my_pane)
    local my_tab
    for _, p in ipairs(panes) do
      if p.pane_id == my_id then
        my_tab = p.tab_id
        break
      end
    end
    if not my_tab then return nil end
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
    vim.system(
      { "wezterm", "cli", "send-text", "--no-paste", "--pane-id", target, key },
      { text = true }
    )
  end
end

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  {
    "vim-denops/denops.vim",
    init = function()
      vim.g["denops#server#deno_args"] = { "-q", "--no-lock", "--unstable-kv", "-A" }
    end,
  },

  {
    "vim-skk/skkeleton",
    dependencies = {
      "vim-denops/denops.vim",
      { "delphinus/skkeleton_indicator.nvim", opts = { fadeOutMs = 0 } },
    },
    lazy = false,
    keys = {
      -- Use these mappings in Karabiner-Elements
      { "<A-j>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" } },
      { "<A-J>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" } },
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
    },
    config = function()
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
    "hrsh7th/nvim-cmp",
    dependencies = {
      "delphinus/cmp-wezterm",
      "hrsh7th/cmp-emoji",
      "lukas-reineke/cmp-rg",
      "octaltree/cmp-look",
      "uga-rosa/cmp-skkeleton",
      { "delphinus/cmp-async-path", option = { show_hidden_files_by_default = true } },
    },
    config = function()
      local cmp = require "cmp"
      local types = require "cmp.types"
      cmp.setup {
        sources = {
          { name = "wezterm", keyword_length = 2, option = {} },
          { name = "async_path" },
          { name = "rg", keyword_length = 4, option = { debounce = 0 } },
          { name = "emoji" },
          { name = "look", keyword_length = 4, option = { convert_case = true, loud = true } },
        },
        mapping = {
          ["<CR>"] = cmp.mapping.confirm { select = false },
          ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif send_key_to_pane then
              send_key_to_pane("\x1b[B")
            else
              fallback()
            end
          end, { "i", "c" }),
          ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif send_key_to_pane then
              send_key_to_pane("\x1b[A")
            else
              fallback()
            end
          end, { "i", "c" }),
          ["<A-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<A-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-e>"] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
        },
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              wezterm = "[W]",
              async_path = "[P]",
              rg = "[R]",
              emoji = "[E]",
              look = "[L]",
            })[entry.source.name]
            return vim_item
          end,
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            -- cmp.config.compare.scopes,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            -- cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
      }

      vim.api.nvim_create_autocmd("User", {
        pattern = "skkeleton-enable-pre",
        callback = function()
          cmp.setup.buffer {
            formatting = { fields = { types.cmp.ItemField.Abbr } },
            sources = { { name = "skkeleton", keyword_pattern = [=[\V\[ーぁ-ゔァ-ヴｦ-ﾟ]]=] } },
            sorting = {
              priority_weight = 2,
              comparators = {
                cmp.config.compare.recently_used,
                cmp.config.compare.order,
              },
            },
          }
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "skkeleton-disable-pre",
        callback = function()
          cmp.setup.buffer {}
        end,
      })
    end,
  },

  {
    "yuki-yano/fuzzy-motion.vim",
    dependencies = {
      "vim-denops/denops.vim",
      "lambdalisue/kensaku.vim",
    },
    keys = { { "s", "<Cmd>FuzzyMotion<CR>", mode = { "n", "x" } } },
    lazy = false,
    init = function()
      vim.g.fuzzy_motion_labels = vim.split("HJKLASDFGYUIOPQWERTNMZXCVB", "")
      vim.g.fuzzy_motion_matchers = "kensaku,fzf"
    end,
  },
}, { lazy = false })

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
      vim.system(
        { "wezterm", "cli", "send-text", "--no-paste", "--pane-id", target, "\r" },
        { text = true },
        function()
          vim.schedule(function()
            vim.cmd "startinsert"
          end)
        end
      )
      return
    end
    -- @ で終わる場合はスペースを付ける（editprompt の processContent と同じ）
    if content:match("@[^\n]*$") then
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
                vim.notify("editprompt failed to send Enter: " .. (obj2.stderr or "unknown error"), vim.log.levels.ERROR)
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
  vim.keymap.set("i", "<C-u>", function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if table.concat(lines, "\n") == "" then
      send_key_to_pane("\x15")
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-u>", true, false, true), "n", false)
    end
  end, { silent = true, desc = "Send C-u to sibling pane when buffer is empty" })
end
