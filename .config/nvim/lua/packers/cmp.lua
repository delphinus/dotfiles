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
              keyword_pattern = [[\k\+\%(\%(-\k\+\)\|\%(::\k\+\)\)*]],
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
                hi CmpItemAbbrDeprecated gui=bold guifg=#616e88
                hi CmpItemAbbrMatch guifg=#ebcb8b
                hi CmpItemAbbrMatchFuzzy guifg=#d08770
                hi CmpItemKindClass guifg=#ebcb8b
                hi CmpItemKindFunction guifg=#b48ead
                hi CmpItemKindInterface guifg=#8fbcbb
                hi CmpItemKindKeyword guifg=#5e81ac
                hi CmpItemKindMethod guifg=#b48ead
                hi CmpItemKindProperty guifg=#a3be8c
                hi CmpItemKindSnippet guifg=#d08770
                hi CmpItemKindField guifg=#a3be8c
                hi CmpItemKindText guifg=#81a1c1
                hi CmpItemKindUnit guifg=#b48ead
                hi CmpItemKindVariable guifg=#88c0d0
              ]]
            end,
          },
        },
      }
    end,
  },
}
