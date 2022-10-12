return {
  skkeleton = {
    setup = function()
      local fn, _, api = require("core.utils").globals()
      local keymap = vim.keymap

      -- Use these mappings in Karabiner-Elements
      keymap.set({ "i", "c", "l" }, "<F10>", "<Plug>(skkeleton-disable)")
      keymap.set({ "i", "c", "l" }, "<F13>", "<Plug>(skkeleton-enable)")
      keymap.set({ "i", "c", "l" }, "<C-j>", "<Plug>(skkeleton-toggle)")
      keymap.set("i", "<C-x><C-o>", function()
        require("cmp").complete()
      end)

      local Job = require "plenary.job"
      local karabiner_cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
      local function set_karabiner(val)
        return function()
          Job:new({
            command = karabiner_cli,
            args = {
              "--set-variables",
              ('{"neovim_in_insert_mode":%d}'):format(val),
            },
          }):start()
        end
      end

      --[[
      local pre_config

      local g1 = api.create_augroup("skkeleton_callbacks", {})
      api.create_autocmd("User", {
        group = g1,
        pattern = "skkeleton-enable-pre",
        callback = function()
          pre_config = require("cmp.config").get()
          require("cmp").setup.buffer {
            sources = { { name = "skkeleton" } },
            view = { entries = "native" },
          }
        end,
      })
      api.create_autocmd("User", {
        group = g1,
        pattern = "skkeleton-disable-pre",
        callback = function()
          if pre_config then
            require("cmp").setup.buffer(pre_config)
            pre_config = nil
          end
        end,
      })
      ]]

      local g2 = api.create_augroup("skkeleton_karabiner_elements", {})
      api.create_autocmd({ "InsertEnter", "CmdlineEnter" }, { group = g2, callback = set_karabiner(1) })
      api.create_autocmd({ "InsertLeave", "CmdlineLeave", "FocusLost" }, { group = g2, callback = set_karabiner(0) })
      api.create_autocmd("FocusGained", {
        group = g2,
        callback = function()
          local val = fn.mode():match "[icrR]" and 1 or 0
          set_karabiner(val)()
        end,
      })
    end,

    config = function()
      local fn = vim.fn

      fn["skkeleton#config"] {
        globalJisyo = "~/Library/Application Support/AquaSKK/SKK-JISYO.L",
        userJisyo = "~/Library/Application Support/AquaSKK/skk-jisyo.utf8",
        markerHenkan = "□",
        eggLikeNewline = true,
        useSkkServer = true,
        immediatelyCancel = false,
        registerConvertResult = true,
      }
      fn["skkeleton#register_kanatable"]("rom", {
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
        ["/"] = { "・", "" },
        ["<s-q>"] = "henkanPoint",
      })
    end,
  },

  skkeleton_indicator = {
    setup = function()
      local api = require("core.utils").api
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("skkeleton_indicator_nord", {}),
        pattern = "nord",
        callback = function()
          api.set_hl(0, "SkkeletonIndicatorEiji", { fg = "#88c0d0", bg = "#2e3440", bold = true })
          api.set_hl(0, "SkkeletonIndicatorHira", { fg = "#2e3440", bg = "#a3be8c", bold = true })
          api.set_hl(0, "SkkeletonIndicatorKata", { fg = "#2e3440", bg = "#ebcb8b", bold = true })
          api.set_hl(0, "SkkeletonIndicatorHankata", { fg = "#2e3440", bg = "#b48ead", bold = true })
          api.set_hl(0, "SkkeletonIndicatorZenkaku", { fg = "#2e3440", bg = "#88c0d0", bold = true })
        end,
      })
    end,
  },

  luasnip = function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end,

  cmp = {
    setup = function()
      local api = require("core.utils").api
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("cmp_nord", {}),
        pattern = "nord",
        callback = function()
          api.set_hl(0, "CmpItemAbbrDeprecated", { fg = "#616e88", bold = true })
          api.set_hl(0, "CmpItemAbbrMatch", { fg = "#ebcb8b" })
          api.set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#d08770" })
          api.set_hl(0, "CmpItemMenu", { fg = "#616e88", bold = true })

          api.set_hl(0, "CmpItemKindText", { fg = "#81a1c1" })
          api.set_hl(0, "CmpItemKindMethod", { fg = "#b48ead" })
          api.set_hl(0, "CmpItemKindFunction", { fg = "#b48ead" })
          api.set_hl(0, "CmpItemKindConstructor", { fg = "#b48ead", bold = true })
          api.set_hl(0, "CmpItemKindField", { fg = "#a3be8c" })
          api.set_hl(0, "CmpItemKindVariable", { fg = "#88c0d0" })
          api.set_hl(0, "CmpItemKindClass", { fg = "#ebcb8b" })
          api.set_hl(0, "CmpItemKindInterface", { fg = "#8fbcbb" })
          api.set_hl(0, "CmpItemKindModule", { fg = "#ebcb8b" })
          api.set_hl(0, "CmpItemKindProperty", { fg = "#a3be8c" })
          api.set_hl(0, "CmpItemKindUnit", { fg = "#b48ead" })
          api.set_hl(0, "CmpItemKindValue", { fg = "#8fbcbb" })
          api.set_hl(0, "CmpItemKindEnum", { fg = "#8fbcbb" })
          api.set_hl(0, "CmpItemKindKeyword", { fg = "#5e81ac" })
          api.set_hl(0, "CmpItemKindSnippet", { fg = "#d08770" })
          api.set_hl(0, "CmpItemKindColor", { fg = "#ebcb8b" })
          api.set_hl(0, "CmpItemKindFile", { fg = "#a3be8c" })
          api.set_hl(0, "CmpItemKindReference", { fg = "#b48ead" })
          api.set_hl(0, "CmpItemKindFolder", { fg = "#a3be8c" })
          api.set_hl(0, "CmpItemKindEnumMember", { fg = "#8fbcbb" })
          api.set_hl(0, "CmpItemKindConstant", { fg = "#5e81ac" })
          api.set_hl(0, "CmpItemKindStruct", { fg = "#8fbcbb" })
          api.set_hl(0, "CmpItemKindEvent", { fg = "#d08770" })
          api.set_hl(0, "CmpItemKindOperator", { fg = "#b48ead" })
          api.set_hl(0, "CmpItemKindTypeParameter", { fg = "#8fbcbb" })
        end,
      })
    end,

    config = function()
      local api = require("core.utils").api
      local ignore_duplicated_items = { ctags = true, buffer = true, tmux = true, rg = true, look = true }

      local lspkind_format = require("lspkind").cmp_format {
        mode = "symbol_text",
        maxwidth = 50,
        menu = {
          buffer = "[B]",
          ctags = "[C]",
          digraphs = "[D]",
          emoji = "[E]",
          fish = "[F]",
          look = "[LK]",
          nvim_lsp = "[L]",
          nvim_lua = "[LU]",
          path = "[P]",
          rg = "[R]",
          luasnip = "[S]",
          tmux = "[T]",
          treesitter = "[TS]",
        },
        symbol_map = {
          Text = "󾪓", -- 0xFEA93
          Method = "󾪌", -- 0xFEA8C
          Function = "󾪌", -- 0xFEA8C
          Constructor = "󾪌", -- 0xFEA8C
          Field = "󾭟", -- 0xFEB5F
          Variable = "󾪈", -- 0xFEA88
          Class = "󾭛", -- 0xFEB5B
          Interface = "󾭡", -- 0xFEB61
          Module = "󾪋", -- 0xFEA8B
          Property = "󾭥", -- 0xFEB65
          Unit = "󾪖", -- 0xFEA96
          Value = "󾪕", -- 0xFEA95
          Enum = "󾪕", -- 0xFEA95
          Keyword = "󾭢", -- 0xFEB62
          Snippet = "󾭦", -- 0xFEB66
          Color = "󾭜", -- 0xFEB5C
          File = "󾩻", -- 0xFEA7B
          Reference = "󾪔", -- 0xFEA94
          Folder = "󾪃", -- 0xFEA83
          EnumMember = "󾪕", -- 0xFEA95
          Constant = "󾭝", -- 0xFEB5D
          Struct = "󾪑", -- 0xFEA91
          Event = "󾪆", -- 0xFEA86
          Operator = "󾭤", -- 0xFEB64
          TypeParameter = "󾪒", -- 0xFEA92
        },
      }

      local cmp = require "cmp"
      cmp.setup {
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<CR>"] = cmp.mapping.confirm { select = false },
          ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
          ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
          ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-e>"] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
          ["<C-f>"] = cmp.mapping(function(fallback)
            local luasnip = require "luasnip"
            if luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-b>"] = cmp.mapping(function(fallback)
            local luasnip = require "luasnip"
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            local col = fn.col "." - 1
            if cmp.visible() then
              cmp.select_next_item()
            elseif col == 0 or fn.getline("."):sub(col, col):match "%s" then
              fallback()
            else
              cmp.complete()
            end
          end, { "i", "s" }),
          ["<S-Tab"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          { name = "ctags" },
          { name = "treesitter", trigger_characters = { "." }, option = {} },
          { name = "fish" },
          { name = "digraphs" },
          { name = "luasnip" },
          { name = "tmux", keyword_length = 2, option = { trigger_characters = {}, all_panes = true } },
          {
            name = "buffer",
            option = {
              --keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%([\-.]\w*\)*\)]],
              --keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h[\-:\w]*\%([\-.][:\w]*\)*\)]],
              --keyword_pattern = [[\k\+]],
              -- Allow Foo::Bar & foo-bar
              --keyword_pattern = [[\h\w*\%(\%(-\|::\)\h\w*\)*]],
              --keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(\%(-\|::\)\h\w*\)*\)]],
              keyword_pattern = [[\%(#[\da-fA-F]\{6}\>\|-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(\%(-\|::\)\h\w*\)*\)]],
              get_bufnrs = api.list_bufs,
            },
          },
          { name = "rg" },
          { name = "emoji" },
          { name = "look", keyword_length = 2, option = { convert_case = true, loud = true } },
        },
        formatting = {
          format = function(entry, vim_item)
            if ignore_duplicated_items[entry.source.name] then
              vim_item.dup = true
            end
            return lspkind_format(entry, vim_item)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      }
      cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })
      cmp.setup.cmdline(":", { sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }) })

      require("cmp.utils.debug").flag = vim.env.CMP_DEBUG ~= nil
    end,
  },
}
