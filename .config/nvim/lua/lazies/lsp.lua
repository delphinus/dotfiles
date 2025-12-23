local palette = require "core.utils.palette"

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = {
      { "Bilal2453/luvit-meta" },
      { "DrKJeff16/wezterm-types" },
    },
    ---@module 'lazydev'
    ---@type lazydev.Config
    opts = {
      library = {
        "lazydev.nvim",
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "wezterm-types", mods = { "wezterm" } },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost" },

    dependencies = {
      {
        "williamboman/mason.nvim",
        ---@module 'mason'
        ---@type MasonSettings
        opts = {
          ui = { height = 0.8, border = "rounded" },
          max_concurrent_installers = 12,
          registries = {
            "file:~/.config/nvim/mason",
            "github:mason-org/mason-registry",
          },
        },
      },

      { "williamboman/mason-lspconfig.nvim", opts = {} },

      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        config = function()
          local Interval = require "core.utils.interval"
          local itvl = Interval.new("mason_tool_installer", 24 * 7 * 3600)
          local is_over = itvl:is_over()

          if is_over then
            vim.notify("Tools are old. Updating……", vim.log.levels.WARN)
            vim.api.nvim_create_autocmd("User", {
              pattern = "MasonToolsUpdateCompleted",
              group = vim.api.nvim_create_augroup("mason-tool-installer", {}),
              callback = function()
                vim.notify("Tools are updated.", vim.log.levels.INFO)
                itvl:update()
              end,
            })
          end

          local mason_tool_installer = require "mason-tool-installer"
          mason_tool_installer.setup {
            auto_update = is_over,
            ensure_installed = {
              "ansiblels",
              "buf_ls",
              "clangd",
              -- NOTE: cmake-language-server does not support Python 3.14
              -- "cmake",
              "copilot",
              "cssls",
              "denols",
              "docker_compose_language_service",
              "dockerls",
              "dotls",
              "gofumpt",
              "goimports",
              "golangci-lint",
              "golines",
              "gopls",
              "harper_ls",
              "intelephense",
              "jqls",
              "jsonls",
              "jsonnet_ls",
              "lua_ls",
              "luacheck",
              "marksman",
              "perlnavigator",
              "pyright",
              "rubocop",
              "shellcheck",
              "shfmt",
              "solargraph",
              "stylua",
              "terraformls",
              "ts_ls",
              "vimls",
              "vint",
              "vue_ls",
              "yamlls",
            },
          }
          mason_tool_installer.check_install()
        end,
      },

      { "hrsh7th/cmp-nvim-lsp", opts = {} },
    },

    init = function()
      palette "lspconfig" {
        nord = function(colors)
          vim.api.nvim_set_hl(0, "DiagnosticError", { fg = colors.red })
          vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = colors.orange })
          vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = colors.bright_cyan })
          vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = colors.nord3_bright })
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { sp = colors.red, undercurl = true })
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { sp = colors.orange, undercurl = true })
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { sp = colors.bright_cyan, undercurl = true })
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { sp = colors.nord3_bright, undercurl = true })
          vim.api.nvim_set_hl(0, "LspBorderTop", { fg = colors.border, bg = colors.dark_black })
          vim.api.nvim_set_hl(0, "LspBorderLeft", { fg = colors.border, bg = colors.black })
          vim.api.nvim_set_hl(0, "LspBorderRight", { fg = colors.border, bg = colors.black })
          vim.api.nvim_set_hl(0, "LspBorderBottom", { fg = colors.border, bg = colors.dark_black })
        end,
      }
    end,

    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "Enable LSP feature in my lualine",
        group = vim.api.nvim_create_augroup("enable-lualine-lsp", {}),
        once = true,
        callback = function()
          require("core.utils.lualine").is_lsp_available = true
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "Call the default onAttach func",
        group = vim.api.nvim_create_augroup("common-lsp-on-attach", {}),
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
          require("core.utils.lsp").on_attach(client, args.buf)
        end,
      })

      vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })

      -- NOTE: call here because this function sets LspAttach autocmd
      vim.lsp.on_type_formatting.enable()

      vim.api.nvim_create_autocmd("LspProgress", {
        callback = function(ev)
          local terminal = require "core.utils.terminal"
          local value = ev.data.params.value
          if value.kind == "begin" then
            terminal.progress_start()
          elseif value.kind == "end" then
            terminal.progress_end()
          elseif value.kind == "report" then
            terminal.progress_set(value.percentage)
          end
        end,
      })
    end,
  }, -- }}}

  {
    "dense-analysis/ale",
    event = { "BufReadPost" },
    opts = {
      disable_lsp = 1,
      echo_cursor = 0,
      fix_on_save = 1,
      fixers = { lua = { "stylua" } },
      linters_ignore = { "protoc", "protoc-gen-lint", "javac" },
      virtualtext_cursor = 0,
    },
  },

  { "AbaoFromCUG/nvim-treesitter-endwise", branch = "main" },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",

    dependencies = {
      {
        "andymass/vim-matchup",
        init = function()
          vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
          vim.g.matchup_treesitter_enable_quotes = true
          vim.g.matchup_treesitter_disable_virtual_text = true
          vim.g.matchup_treesitter_include_match_words = true
        end,
      },
    },

    init = function()
      local group = vim.api.nvim_create_augroup("treesitter-detection", {})

      -- HACK: deal with async Tree-sitter detection
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = group,
        callback = function()
          vim.defer_fn(function()
            if vim.bo.filetype == "" then
              pcall(vim.cmd.edit)
            end
          end, 500)
        end,
      })

      local disabled_filetypes = {
        perl = true,
      }

      local loaded_endwise = false
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          if disabled_filetypes[args.match] then
            return
          end
          if not loaded_endwise then
            pcall(require, "nvim-treesitter")
            local ok = pcall(require, "nvim-treesitter-endwise")
            if ok then
              loaded_endwise = true
            end
          end
          pcall(vim.treesitter.start)
        end,
      })
    end,

    build = ":TSUpdate",
    opts = {},
  },

  {
    "soulis-1256/hoverhints.nvim",
    keys = { "<MouseMove>" },
    event = { "DiagnosticChanged" },
    opts = {},
  },

  {
    "Chaitanyabsprip/fastaction.nvim",
    keys = {
      { "gra", '<Cmd>lua require("fastaction").code_action()<CR>', mode = { "n" } },
      { "gra", '<Cmd>lua require("fastaction").range_code_action()<CR>', mode = { "v" } },
    },
    opts = {},
  },
}
