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
    "hrsh7th/nvim-cmp",
    --event = { "InsertEnter" },
    setup = function()
      local cmp = require "cmp"
      cmp.setup {
        mapping = {
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-y>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-e>"] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
          ["<CR>"] = cmp.mapping.confirm { select = true },
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
            if not vim_item.label then
              vim_item.label = "[" .. entry.source.name .. "]"
            end
            print(vim_item.label)
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
