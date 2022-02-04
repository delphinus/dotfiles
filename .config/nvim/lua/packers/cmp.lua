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
    setup = function()
      require("snippy").setup {}
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    --event = { "InsertEnter" },
    setup = function()
      local maxwidth = 50
      local lspkind_format = require("lspkind").cmp_format {
        mode = "symbol_text",
        preset = "codicons",
        maxwidth = maxwidth,
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
          --["<CR>"] = cmp.mapping.confirm { select = true },
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }, {
          { name = "tmux", option = { all_panes = true } },
          { name = "buffer" },
          { name = "rg" },
          { name = "emoji" },
          { name = "look", keyword_length = 2, option = { convert_case = true, loud = true } },
        }),
        formatting = {
          format = function(entry, vim_item)
            local name = entry.source.name
            vim_item.menu = menu[name] or ""
            if name == "nvim_lsp" then
              return lspkind_format(entry, vim_item)
            end
            vim_item.abbr = vim_item.abbr:sub(1, maxwidth)
            return vim_item
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
                hi CmpItemKindVariable guifg=#88c0d0
                hi CmpItemKindInterface guifg=#88c0d0
                hi CmpItemKindText guifg=#88c0d0
                hi CmpItemKindFunction guifg=#b48ead
                hi CmpItemKindMethod guifg=#b48ead
                hi CmpItemKindKeyword guifg=#d8dee9
                hi CmpItemKindProperty guifg=#d8dee9
                hi CmpItemKindUnit guifg=#d8dee9
              ]]
            end,
          },
        },
      }
    end,
  },
}
