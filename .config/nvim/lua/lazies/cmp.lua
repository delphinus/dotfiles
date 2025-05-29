---@diagnostic disable: missing-fields
local utils = require "core.utils"
local lazy_require = require "lazy_require"
local palette = require "core.utils.palette"
local lazy_utils = require "core.utils.lazy"

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
    "willelz/skk-tutorial.vim",
    cmd = { "SKKTutorialStart" },
    dependencies = { "denops.vim", "skkeleton" },
    config = function()
      utils.load_denops_plugin "skk-tutorial.vim"
      vim.wait(1000, function()
        return not not vim.api.nvim_get_commands({}).SKKTutorialStart
      end)
    end,
  },

  {
    "vim-skk/skkeleton",
    keys = {
      -- Use these mappings in Karabiner-Elements
      { "<A-j>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" } },
      { "<A-J>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" } },
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
      { "<C-x><C-o>", lazy_require("cmp").complete(), mode = { "i" }, desc = "Complete by nvim-cmp" },
    },
    dependencies = {
      "denops.vim",
    },

    init = function()
      local karabiner_cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
      local karabiner_exists = not not vim.uv.fs_stat(karabiner_cli)
      if karabiner_exists then
        local function set_karabiner(val)
          return function()
            vim.system { karabiner_cli, "--set-variables", vim.json.encode { neovim_in_insert_mode = val } }
          end
        end

        local g1 = vim.api.nvim_create_augroup("skkeleton_callbacks", {})
        local cmp_config
        vim.api.nvim_create_autocmd("User", {
          desc = "Set up skkeleton settings with nvim-cmp",
          group = g1,
          pattern = "skkeleton-enable-pre",
          callback = function()
            local types = require "cmp.types"
            require("cmp").setup.buffer {
              formatting = { fields = { types.cmp.ItemField.Abbr } },
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
        vim.api.nvim_create_autocmd("User", {
          desc = "Restore the default settings for nvim-cmp",
          group = g1,
          pattern = "skkeleton-disable-pre",
          callback = function()
            require("cmp").setup.buffer(cmp_config)
          end,
        })

        local g2 = vim.api.nvim_create_augroup("skkeleton_karabiner_elements", {})
        vim.api.nvim_create_autocmd(
          { "InsertEnter", "CmdlineEnter" },
          { group = g2, callback = set_karabiner(1), desc = "Enable Karabiner-Elements settings for skkeleton" }
        )
        vim.api.nvim_create_autocmd(
          { "InsertLeave", "CmdlineLeave", "FocusLost" },
          { group = g2, callback = set_karabiner(0), desc = "Disable Karabiner-Elements settings for skkeleton" }
        )
        vim.api.nvim_create_autocmd("FocusGained", {
          desc = "Enable/Disable Karabiner-Elements settings for skkeleton",
          group = g2,
          callback = function()
            local val = not not vim.vim.api.nvim_nvim_get_mode().mode:match "[icrR]" and 1 or 0
            set_karabiner(val)()
          end,
        })
      end
    end,

    config = function()
      utils.load_denops_plugin "skkeleton"

      local function dic(name)
        return { "~/Library/Application Support/AquaSKK/" .. name, name:match "utf8" and "utf-8" or "euc-jp" }
      end

      vim.fn["skkeleton#config"] {
        globalDictionaries = {
          dic "SKK-JISYO.L",
          dic "SKK-JISYO.jinmei",
          --dic "SKK-JISYO.fullname",
          dic "SKK-JISYO.fullname.utf8",
          dic "SKK-JISYO.geo",
          dic "SKK-JISYO.propernoun",
          dic "SKK-JISYO.station",
          dic "SKK-JISYO.law",
          dic "SKK-JISYO.china_taiwan",
          dic "SKK-JISYO.assoc",
          dic "SKK-JISYO.zipcode",
          dic "SKK-JISYO.office.zipcode",
          dic "SKK-JISYO.JIS2",
          --dic "SKK-JISYO.JIS3_4",
          dic "SKK-JISYO.JIS3_4.utf8",
          --dic "SKK-JISYO.JIS2004",
          dic "SKK-JISYO.JIS2004.utf8",
          dic "SKK-JISYO.itaiji",
          --dic "SKK-JISYO.itaiji.JIS3_4",
          dic "SKK-JISYO.itaiji.JIS3_4.utf8",
          dic "SKK-JISYO.mazegaki",
          dic "SKK_JISYO.shikakugoma",
          dic "SKK-JISYO.emoji.utf8",
          dic "SKK-JISYO.emoji-ja.utf8",
          dic "SKK-JISYO.jawiki.utf8",
        },
        userDictionary = vim.fs.normalize "~/Documents/skk-jisyo.utf8",
        eggLikeNewline = true,
        immediatelyCancel = false,
        registerConvertResult = true,
        sources = { "deno_kv", "google_japanese_input" },
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

  { "hrsh7th/cmp-nvim-lua", ft = "lua" },
  { "mtoohey31/cmp-fish", ft = "fish" },

  c { "hrsh7th/cmp-cmdline" },
  c { "hrsh7th/cmp-path" },

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
  i { "uga-rosa/cmp-skkeleton" },

  { "rafamadriz/friendly-snippets" },
  {
    "L3MON4D3/LuaSnip",
    config = lazy_require("luasnip.loaders.from_vscode").lazy_load(),
  },
  i { "saadparwaiz1/cmp_luasnip" },

  i { "delphinus/cmp-ghq" },

  i { "zbirenbaum/copilot-cmp", opts = {} },

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
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.green })
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
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.green })
        end,
      }
    end,

    config = function()
      local cmp = require "cmp"
      local types = require "cmp.types"
      local comparators = {
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
      }
      if lazy_utils.has_plugin "copilot-cmp" then
        table.insert(comparators, 1, require("copilot_cmp.comparators").prioritize)
      end

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
            copilot = "O",
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
            path = "P",
            rg = "R",
            treesitter = "T",
            wezterm = "W",
          },
          preset = "codicons",
          symbol_map = { Copilot = "" },
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
        { name = "digraphs", keyword_length = 1 },
        { name = "path" },
        { name = "lazydev", group_index = 0 },
        { name = "nvim_lsp" },
        { name = "copilot" },
        { name = "nvim_lua" },
        { name = "git" },
        { name = "ctags" },
        { name = "treesitter", trigger_characters = { "." }, option = {} },
        { name = "fish" },
        { name = "luasnip" },
        { name = "wezterm", keyword_length = 2, option = {} },
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
        },
        { name = "ghq" },
        { name = "rg", keyword_length = 4, option = { debounce = 0 } },
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
          comparators = comparators,
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
