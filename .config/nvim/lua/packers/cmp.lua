return {
  { "andersevenrud/cmp-tmux" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/cmp-emoji" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-path" },
  { "lukas-reineke/cmp-rg" },
  { "octaltree/cmp-look" },
  { "onsails/lspkind-nvim" },
  { "rinx/cmp-skkeleton" },

  {
    "dcampos/cmp-snippy",
    requires = {
      "dcampos/nvim-snippy",
      "honza/vim-snippets",
    },
    config = function()
      require("snippy").setup {}
    end,
  },

  {
    "delphinus/skkeleton_indicator.nvim",
    event = { "InsertEnter" },
    config = function()
      vim.cmd [[
            hi SkkeletonIndicatorEiji guifg=#88c0d0 guibg=#2e3440 gui=bold
            hi SkkeletonIndicatorHira guifg=#2e3440 guibg=#a3be8c gui=bold
            hi SkkeletonIndicatorKata guifg=#2e3440 guibg=#ebcb8b gui=bold
            hi SkkeletonIndicatorHankata guifg=#2e3440 guibg=#b48ead gui=bold
            hi SkkeletonIndicatorZenkaku guifg=#2e3440 guibg=#88c0d0 gui=bold
          ]]
      require("skkeleton_indicator").setup()
    end,
  },

  {
    --'vim-skk/skkeleton',
    "delphinus/skkeleton",
    branch = "feature/inform-mode-change-immediately",
    keys = {
      { "i", "<Plug>(skkeleton-enable)" },
      { "i", "<Plug>(skkeleton-disable)" },
      { "c", "<Plug>(skkeleton-enable)" },
      { "c", "<Plug>(skkeleton-disable)" },
      { "l", "<Plug>(skkeleton-enable)" },
      { "l", "<Plug>(skkeleton-disable)" },
    },
    wants = {
      "denops.vim",
    },
    setup = function()
      -- Use these mappings in Karabiner-Elements
      vim.keymap.set({ "i", "c", "l" }, "<F10>", "<Plug>(skkeleton-disable)")
      vim.keymap.set({ "i", "c", "l" }, "<F13>", "<Plug>(skkeleton-enable)")
      vim.keymap.set({ "i", "c", "l" }, "<C-j>", "<Plug>(skkeleton-enable)")

      local Job = require "plenary.job"
      local karabiner_cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
      local function set_karabiner(val)
        return function()
          Job
            :new({
              command = karabiner_cli,
              args = {
                "--set-variables",
                ('{"neovim_in_insert_mode":%d}'):format(val),
              },
            })
            :start()
        end
      end

      local cmp = require "cmp"
      local cmp_config = require "cmp.config"
      local pre_config
      require("agrp").set {
        skkeleton_callbacks = {
          {
            "User",
            "skkeleton-enable-pre",
            function()
              pre_config = cmp_config.get()
              cmp.setup.buffer {
                sources = { { name = "skkeleton" } },
                experimental = { native_menu = true },
              }
            end,
          },
          {
            "User",
            "skkeleton-disable-pre",
            function()
              if pre_config then
                cmp.setup.buffer(pre_config)
                pre_config = nil
              end
            end,
          },
        },
        skkeleton_karabiner_elements = {
          { "InsertEnter,CmdlineEnter", "*", set_karabiner(1) },
          { "InsertLeave,CmdlineLeave,FocusLost", "*", set_karabiner(0) },
          {
            "FocusGained",
            "*",
            function()
              local val = fn.mode():match "[icrR]" and 1 or 0
              set_karabiner(val)()
            end,
          },
        },
      }
    end,
    config = function()
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

  {
    "hrsh7th/nvim-cmp",
    --event = { "InsertEnter" },
    config = function()
      local maxwidth = 50
      local lspkind_format = require("lspkind").cmp_format {
        mode = "symbol_text",
        maxwidth = maxwidth,
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
      local menu = {
        buffer = "[B]",
        emoji = "[E]",
        look = "[LK]",
        nvim_lsp = "[L]",
        path = "[P]",
        rg = "[R]",
        snippy = "[S]",
        tmux = "[T]",
      }
      local cmp = require "cmp"
      cmp.setup {
        snippet = {
          expand = function(args)
            require("snippy").expand_snippet(args.body)
          end,
        },
        mapping = {
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-y>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-e>"] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
          ["<CR>"] = cmp.mapping.confirm { select = true },
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "snippy" },
          { name = "tmux", keyword_length = 2, option = { trigger_characters = {}, all_panes = true } },
          {
            name = "buffer",
            option = {
              --keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%([\-.]\w*\)*\)]],
              --keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h[\-:\w]*\%([\-.][:\w]*\)*\)]],
              --keyword_pattern = [[\k\+]],
              -- Allow Foo::Bar & foo-bar
              --keyword_pattern = [[\h\w*\%(\%(-\|::\)\h\w*\)*]],
              keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(\%(-\|::\)\h\w*\)*\)]],
              get_bufnrs = function()
                return api.list_bufs()
              end,
            },
          },
          { name = "rg" },
          { name = "emoji" },
          { name = "look", keyword_length = 2, option = { convert_case = true, loud = true } },
        },
        formatting = {
          format = function(entry, vim_item)
            local name = entry.source.name
            vim_item.menu = menu[name] or ""
            return lspkind_format(entry, vim_item)
          end,
        },
      }
      cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })
      cmp.setup.cmdline(":", { sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }) })

      require("agrp").set {
        cmp_nord = {
          {
            "ColorScheme",
            "nord",
            function()
              vim.cmd [[
                hi CmpItemAbbrDeprecated guifg=#616e88 gui=bold
                hi CmpItemAbbrMatch guifg=#ebcb8b
                hi CmpItemAbbrMatchFuzzy guifg=#d08770

                hi CmpItemKindText guifg=#81a1c1
                hi CmpItemKindMethod guifg=#b48ead
                hi CmpItemKindFunction guifg=#b48ead
                hi CmpItemKindConstructor guifg=#b48ead gui=bold
                hi CmpItemKindField guifg=#a3be8c
                hi CmpItemKindVariable guifg=#88c0d0
                hi CmpItemKindClass guifg=#ebcb8b
                hi CmpItemKindInterface guifg=#8fbcbb
                hi CmpItemKindModule guifg=#ebcb8b
                hi CmpItemKindProperty guifg=#a3be8c
                hi CmpItemKindUnit guifg=#b48ead
                hi CmpItemKindValue guifg=#8fbcbb
                hi CmpItemKindEnum guifg=#8fbcbb
                hi CmpItemKindKeyword guifg=#5e81ac
                hi CmpItemKindSnippet guifg=#d08770
                hi CmpItemKindColor guifg=#ebcb8b
                hi CmpItemKindFile guifg=#a3be8c
                hi CmpItemKindReference guifg=#b48ead
                hi CmpItemKindFolder guifg=#a3be8c
                hi CmpItemKindEnumMember guifg=#8fbcbb
                hi CmpItemKindConstant guifg=#5e81ac
                hi CmpItemKindStruct guifg=#8fbcbb
                hi CmpItemKindEvent guifg=#d08770
                hi CmpItemKindOperator guifg=#b48ead
                hi CmpItemKindTypeParameter guifg=#8fbcbb
              ]]
            end,
          },
        },
      }
    end,
  },
}
