---@diagnostic disable: missing-fields
local lazy_require = require "lazy_require"
local palette = require "core.utils.palette"

local function i(p)
  p.event = { "InsertEnter" }
  return p
end

local function c(p)
  p.event = { "CmdlineEnter" }
  return p
end

local function ic(p)
  p.event = { "InsertEnter", "CmdlineEnter" }
  return p
end

return {
  { "hrsh7th/cmp-nvim-lua", ft = "lua" },
  { "mtoohey31/cmp-fish", ft = "fish" },

  c { "hrsh7th/cmp-cmdline" },
  ic { "delphinus/cmp-async-path" },

  i { "delphinus/cmp-ctags" },
  i { "delphinus/cmp-repo" },
  i { "delphinus/cmp-wezterm" },
  i { "dmitmel/cmp-digraphs" },
  i { "hrsh7th/cmp-buffer" },
  i { "hrsh7th/cmp-emoji" },
  i { "lukas-reineke/cmp-rg" },
  -- i { "delphinus/cmp-rg", branch = "feat/uv" },
  i { "octaltree/cmp-look" },
  i {
    "petertriho/cmp-git",
    opts = function()
      return vim.env.GITHUB_ENTERPRISE_HOST and { github = { hosts = vim.split(vim.env.GITHUB_ENTERPRISE_HOST, ",") } }
        or {}
    end,
  },
  i { "ray-x/cmp-treesitter" },

  { "rafamadriz/friendly-snippets" },
  {
    "L3MON4D3/LuaSnip",
    config = lazy_require("luasnip.loaders.from_vscode").lazy_load(),
  },
  i { "saadparwaiz1/cmp_luasnip" },

  i { "delphinus/cmp-ghq" },

  { "onsails/lspkind-nvim" },
  { "xzbdmw/colorful-menu.nvim" },
  {
    "hrsh7th/nvim-cmp",

    init = function()
      palette "cmp" {
        nord = function(colors)
          vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = colors.brighter_black, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.orange })
          vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.brighter_black, bold = true })

          vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = colors.blue })
          vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = colors.magenta })
          vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = colors.magenta })
          vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { fg = colors.magenta, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = colors.green })
          vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = colors.cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = colors.green })
          vim.api.nvim_set_hl(0, "CmpItemKindUnit", { fg = colors.magenta })
          vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindEnum", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = colors.dark_blue })
          vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = colors.orange })
          vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = colors.green })
          vim.api.nvim_set_hl(0, "CmpItemKindReference", { fg = colors.magenta })
          vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = colors.green })
          vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = colors.dark_blue })
          vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindEvent", { fg = colors.orange })
          vim.api.nvim_set_hl(0, "CmpItemKindOperator", { fg = colors.magenta })
          vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { fg = colors.bright_cyan })
        end,
        sweetie = function(colors)
          vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = colors.dark_grey, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.orange })
          vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.dark_grey, bold = true })

          vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = colors.blue })
          vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = colors.magenta })
          vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = colors.magenta })
          vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { fg = colors.magenta, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = colors.green })
          vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = colors.cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = colors.green })
          vim.api.nvim_set_hl(0, "CmpItemKindUnit", { fg = colors.magenta })
          vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindEnum", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = colors.dark_blue })
          vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = colors.orange })
          vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = colors.green })
          vim.api.nvim_set_hl(0, "CmpItemKindReference", { fg = colors.magenta })
          vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = colors.green })
          vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = colors.dark_blue })
          vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "CmpItemKindEvent", { fg = colors.orange })
          vim.api.nvim_set_hl(0, "CmpItemKindOperator", { fg = colors.magenta })
          vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { fg = colors.bright_cyan })
        end,
      }
    end,

    config = function()
      local cmp = require "cmp"
      local types = require "cmp.types"

      local format = function(entry, vim_item)
        local highlights_info = require("colorful-menu").cmp_highlights(entry)
        if highlights_info then
          vim_item.abbr_hl_group = highlights_info.highlights
          vim_item.abbr = highlights_info.text
        end

        local kind = require("lspkind").cmp_format {
          mode = "symbol",
          maxwidth = 50,
          menu = {
            buffer = "B",
            ctags = "C",
            digraphs = "D",
            emoji = "E",
            fish = "F",
            ghq = "Q",
            git = "G",
            lazydev = "V",
            look = "K",
            luasnip = "S",
            nvim_lsp = "L",
            nvim_lua = "U",
            async_path = "P",
            ["render-markdown"] = "M",
            rg = "R",
            treesitter = "T",
            wezterm = "W",
          },
          preset = "codicons",
          show_labelDetails = true,
          before = function(_, lk_vim_item)
            if lk_vim_item.menu then
              lk_vim_item.menu = " " .. lk_vim_item.menu
            end
            return lk_vim_item
          end,
        }(entry, vim_item)
        vim_item.kind = kind.kind
        vim_item.dup = true

        return vim_item
      end

      local sources = {
        { name = "async_path", option = { show_hidden_files_by_default = true }, priority = 1000 },
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
            get_bufnrs = vim.api.nvim_list_bufs,
          },
          priority = 900,
        },
        { name = "nvim_lsp", priority = 800 },
        { name = "wezterm", keyword_length = 2, option = {}, priority = 800 },
        { name = "rg", keyword_length = 4, option = { debounce = 0 }, priority = 700 },
        { name = "render-markdown" },
        { name = "digraphs", keyword_length = 1 },
        { name = "lazydev", group_index = 0 },
        { name = "nvim_lua" },
        { name = "git" },
        { name = "ctags" },
        { name = "treesitter", trigger_characters = { "." }, option = {} },
        { name = "fish" },
        { name = "luasnip" },
        { name = "ghq" },
        { name = "emoji" },
        { name = "look", keyword_length = 4, option = { convert_case = true, loud = true } },
      }

      cmp.setup {
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        performace = {
          debounce = 0,
          throttle = 0,
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
          --[[ ["<Tab>"] = cmp.mapping(function(fallback)
            local col = vim.fn.col "." - 1
            if cmp.visible() then
              cmp.select_next_item()
            elseif col == 0 or vim.api.nvim_get_current_line():sub(col, col):match "%s" then
              fallback()
            else
              cmp.complete()
            end
          end, { "i", "s" }), ]]
          ["<Tab>"] = vim.schedule_wrap(function(fallback)
            local function has_words_before()
              if vim.bo.buftype == "prompt" then
                return false
              end
              local line, col = unpack(vim.api.nvim_win_get_cursor(0))
              local is_empty_line = vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match "^%s*$"
              return col ~= 0 and not is_empty_line
            end
            if cmp.visible() and has_words_before() then
              cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
            else
              fallback()
            end
          end),
          ["<S-Tab"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = sources,
        formatting = {
          fields = { types.cmp.ItemField.Kind, types.cmp.ItemField.Abbr, types.cmp.ItemField.Menu },
          format = format,
        },
        window = {
          --completion = cmp.config.window.bordered(),
          completion = vim.tbl_extend("force", cmp.config.window.bordered(), {
            border = { { "⡠" }, { "⠤" }, { "⢄" }, { "⢸" }, { "⠊" }, { "⠒" }, { "⠑" }, { "⡇" } },
          }),
          documentation = vim.tbl_extend("force", cmp.config.window.bordered(), {
            border = { { "⡠" }, { "⠤" }, { "⢄" }, { "⢸" }, { "⠊" }, { "⠒" }, { "⠑" }, { "⡇" } },
          }),
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
      if not vim.env.LIGHT then
        cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })
        cmp.setup.cmdline(":", {
          sources = cmp.config.sources(
            { { name = "path" } },
            { { name = "cmdline" }, { name = "ghq" }, { name = "git" } }
          ),
        })
      end

      cmp.setup.filetype({ "markdown" }, {
        sources = vim
          .iter(sources)
          :filter(function(v)
            return v.name ~= "ctags" and v.name ~= "treesitter"
          end)
          :totable(),
      })

      require("cmp.utils.debug").flag = vim.env.CMP_DEBUG ~= nil
    end,
  },
}
