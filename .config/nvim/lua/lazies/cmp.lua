local fn, _, api = require("core.utils").globals()
local lazy_require = require "lazy_require"
local palette = require "core.utils.palette" "nord"

local function i(p)
  p.event = { "InsertEnter" }
  return p
end

local function c(p)
  p.event = { "CmdlineEnter" }
  return p
end

return {
  {
    "vim-skk/skkeleton",
    keys = {
      -- Use these mappings in Karabiner-Elements
      { "<F10>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" } },
      { "<F13>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" } },
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
      { "<C-x><C-o>", lazy_require("cmp").complete(), mode = { "i" } },
    },
    dependencies = {
      "denops.vim",
    },

    init = function()
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

      local g1 = api.create_augroup("skkeleton_callbacks", {})
      local cmp_config
      api.create_autocmd("User", {
        group = g1,
        pattern = "skkeleton-enable-pre",
        callback = function()
          cmp_config = require("cmp.config").get()
          local compare = require "cmp.config.compare"
          require("cmp").setup.buffer {
            formatting = {
              format = function(_, vim_item)
                vim_item.kind = nil
                return vim_item
              end,
            },
            sorting = { comparators = { compare.order } },
            sources = {
              {
                name = "skkeleton",
                entry_filter = function(entry)
                  return entry.completion_item.label ~= ""
                end,
              },
            },
          }
        end,
      })
      api.create_autocmd("User", {
        group = g1,
        pattern = "skkeleton-disable-pre",
        callback = function()
          require("cmp").setup.buffer(cmp_config)
        end,
      })

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
      -- TODO: is this correct?
      fn["denops#plugin#register"] "skkeleton"

      local function dic(name)
        return { "~/Library/Application Support/AquaSKK/" .. name, name:match "utf8" and "utf-8" or "euc-jp" }
      end

      fn["skkeleton#config"] {
        globalDictionaries = {
          dic "SKK-JISYO.L",
          dic "SKK-JISYO.jinmei",
          dic "SKK-JISYO.fullname",
          dic "SKK-JISYO.geo",
          dic "SKK-JISYO.station",
          dic "SKK-JISYO.zipcode",
          dic "SKK-JISYO.office.zipcode",
          dic "SKK-JISYO.JIS2",
          dic "SKK-JISYO.JIS3_4",
          dic "SKK-JISYO.JIS2004",
          dic "SKK-JISYO.itaiji",
          dic "SKK-JISYO.itaiji.JIS3_4",
          dic "SKK-JISYO.mazegaki",
          dic "SKK_JISYO.shikakugoma",
          dic "SKK_JISYO.emoji.utf8",
          dic "SKK_JISYO.emoji-ja.utf8",
        },
        userJisyo = "~/Library/Application Support/AquaSKK/skk-jisyo.utf8",
        eggLikeNewline = true,
        -- TODO: cannot use this with cmp-skkeleton?
        --useSkkServer = true,
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

  i {
    "delphinus/skkeleton_indicator.nvim",

    init = function()
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("skkeleton_indicator_nord", {}),
        pattern = "nord",
        callback = function()
          api.set_hl(0, "SkkeletonIndicatorEiji", { fg = palette.cyan, bg = palette.dark_black, bold = true })
          api.set_hl(0, "SkkeletonIndicatorHira", { fg = palette.dark_black, bg = palette.green, bold = true })
          api.set_hl(0, "SkkeletonIndicatorKata", { fg = palette.dark_black, bg = palette.yellow, bold = true })
          api.set_hl(0, "SkkeletonIndicatorHankata", { fg = palette.dark_black, bg = palette.magenta, bold = true })
          api.set_hl(0, "SkkeletonIndicatorZenkaku", { fg = palette.dark_black, bg = palette.cyan, bold = true })
        end,
      })
    end,

    opts = { alwaysShown = false, fadeOutMs = 0 },
  },

  { "hrsh7th/cmp-nvim-lua", ft = "lua" },
  { "mtoohey31/cmp-fish", ft = "fish" },

  c { "hrsh7th/cmp-cmdline" },
  c { "hrsh7th/cmp-path" },

  i { "andersevenrud/cmp-tmux" },
  i { "delphinus/cmp-ctags" },
  i { "dmitmel/cmp-digraphs" },
  i { "hrsh7th/cmp-buffer" },
  i { "hrsh7th/cmp-emoji" },
  i { "hrsh7th/cmp-nvim-lsp" },
  i { "lukas-reineke/cmp-rg" },
  i { "octaltree/cmp-look" },
  i { "ray-x/cmp-treesitter" },
  i { "uga-rosa/cmp-skkeleton" },

  i {
    "saadparwaiz1/cmp_luasnip",
    dependencies = {
      { "rafamadriz/friendly-snippets" },
      {
        "L3MON4D3/LuaSnip",
        config = lazy_require("luasnip.loaders.from_vscode").lazy_load(),
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "onsails/lspkind-nvim" },
    },

    init = function()
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("cmp_nord", {}),
        pattern = "nord",
        callback = function()
          api.set_hl(0, "CmpItemAbbrDeprecated", { fg = palette.brighter_black, bold = true })
          api.set_hl(0, "CmpItemAbbrMatch", { fg = palette.yellow })
          api.set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = palette.orange })
          api.set_hl(0, "CmpItemMenu", { fg = palette.brighter_black, bold = true })

          api.set_hl(0, "CmpItemKindText", { fg = palette.blue })
          api.set_hl(0, "CmpItemKindMethod", { fg = palette.magenta })
          api.set_hl(0, "CmpItemKindFunction", { fg = palette.magenta })
          api.set_hl(0, "CmpItemKindConstructor", { fg = palette.magenta, bold = true })
          api.set_hl(0, "CmpItemKindField", { fg = palette.green })
          api.set_hl(0, "CmpItemKindVariable", { fg = palette.cyan })
          api.set_hl(0, "CmpItemKindClass", { fg = palette.yellow })
          api.set_hl(0, "CmpItemKindInterface", { fg = palette.bright_cyan })
          api.set_hl(0, "CmpItemKindModule", { fg = palette.yellow })
          api.set_hl(0, "CmpItemKindProperty", { fg = palette.green })
          api.set_hl(0, "CmpItemKindUnit", { fg = palette.magenta })
          api.set_hl(0, "CmpItemKindValue", { fg = palette.bright_cyan })
          api.set_hl(0, "CmpItemKindEnum", { fg = palette.bright_cyan })
          api.set_hl(0, "CmpItemKindKeyword", { fg = palette.dark_blue })
          api.set_hl(0, "CmpItemKindSnippet", { fg = palette.orange })
          api.set_hl(0, "CmpItemKindColor", { fg = palette.yellow })
          api.set_hl(0, "CmpItemKindFile", { fg = palette.green })
          api.set_hl(0, "CmpItemKindReference", { fg = palette.magenta })
          api.set_hl(0, "CmpItemKindFolder", { fg = palette.green })
          api.set_hl(0, "CmpItemKindEnumMember", { fg = palette.bright_cyan })
          api.set_hl(0, "CmpItemKindConstant", { fg = palette.dark_blue })
          api.set_hl(0, "CmpItemKindStruct", { fg = palette.bright_cyan })
          api.set_hl(0, "CmpItemKindEvent", { fg = palette.orange })
          api.set_hl(0, "CmpItemKindOperator", { fg = palette.magenta })
          api.set_hl(0, "CmpItemKindTypeParameter", { fg = palette.bright_cyan })
        end,
      })
    end,

    config = function()
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
          ["<A-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<A-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
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
            elseif col == 0 or api.get_current_line():sub(col, col):match "%s" then
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
