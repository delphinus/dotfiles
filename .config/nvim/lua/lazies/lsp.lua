local palette = require "core.utils.palette"

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = {
      { "Bilal2453/luvit-meta" },
      { "justinsgithub/wezterm-types" },
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
              "cmake",
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
              "volar",
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
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          require("core.utils.lsp").on_attach(client, args.buf)
        end,
      })

      vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
      vim.lsp.enable(require("mason-lspconfig").get_installed_servers())

      -- HACK: disable ideals temporarily
      -- if not configs.ideals then
      if false then
        vim.lsp.config("ideals", {
          default_config = {
            cmd = {
              vim.fs.normalize "~/Applications/IntelliJ IDEA Ultimate 2023.1.7.app/Contents/MacOS/idea",
              "lsp-server",
            },
            filetypes = { "java", "jproperties", "xml" },
            root_markers = { ".git", ".git/", "package.json" },
          },
        })
        vim.lsp.enable "ideals"
      end
    end,
  }, -- }}}

  {
    "dense-analysis/ale",
    event = { "BufReadPost" },
    -- init = function()
    --   vim.api.nvim_create_autocmd("FileType", {
    --     group = vim.api.nvim_create_augroup("ale-filetype", {}),
    --     callback = function(args)
    --       if args.match ~= "markdown" then
    --         local config = vim.api.nvim_win_get_config(0)
    --         local is_floatwin = config.relative ~= ""
    --         if is_floatwin then
    --           return
    --         end
    --         local ignores = vim.b.ale_linters_ignore or {}
    --         if vim.list_contains(ignores, "cspell") then
    --           return
    --         end
    --         table.insert(ignores, "cspell")
    --         vim.b.ale_linters_ignore = ignores
    --         vim.print { ale = vim.b.ale_linters_ignore }
    --       end
    --     end,
    --   })
    -- end,
    opts = {
      disable_lsp = 1,
      echo_cursor = 0,
      fix_on_save = 1,
      fixers = { lua = { "stylua" } },
      linters_ignore = { "cspell", "protoc", "protoc-gen-lint", "javac" },
      virtualtext_cursor = 0,
    },
  },

  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPost" },

    dependencies = {
      { "davidmh/cspell.nvim" },
    },

    config = function()
      local nls = require "null-ls"

      local cspell = require "cspell"
      local cspell_config = {
        on_add_to_json = function(payload)
          vim.system({ "jq", "-S", ".words |= sort", payload.cspell_config_path }, { text = true }, function(job)
            if job.code ~= 0 then
              vim.notify(("failed to arrange %s by jq"):format(payload.cspell_config_path), vim.log.levels.WARN)
              return
            end
            local ok, err = pcall(function()
              io.open(payload.cspell_config_path, "w"):write(job.stdout)
            end)
            if not ok then
              vim.notify(("failed to save arranged JSON: %s"):format(err), vim.log.levels.WARN)
            end
          end)
        end,
      }
      local sources = {
        nls.builtins.code_actions.gitsigns,
        cspell.code_actions.with { filetypes = { "markdown", "help" }, config = cspell_config },
        cspell.diagnostics.with { filetypes = { "markdown", "help" }, config = cspell_config },
      }
      nls.setup {
        diagnostics_format = "[none-ls] #{m}",
        sources = sources,
      }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",

    dependencies = {
      -- { "RRethy/nvim-treesitter-endwise" },
      { "metiulekm/nvim-treesitter-endwise" },
      { "nvim-treesitter/nvim-treesitter-refactor" },
      { "nvim-treesitter/nvim-treesitter-textobjects" },
    },

    event = { "BufReadPost", "BufNewFile", "InsertEnter" },
    build = ":TSUpdate",
    keys = { { "<Space>h", "<Cmd>Inspect<CR>" } },
    config = function()
      require("nvim-treesitter.configs").setup {
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        ensure_installed = "all",
        highlight = { enable = true },
        incremental_selection = { enable = true },
        indent = { enable = true },
        modules = {},
        textobjects = {
          select = {
            enable = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["aC"] = "@class.outer",
              ["iC"] = "@class.inner",
              ["ac"] = "@conditional.outer",
              ["ic"] = "@conditional.inner",
              ["ae"] = "@block.outer",
              ["ie"] = "@block.inner",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
              ["is"] = "@statement.inner",
              ["as"] = "@statement.outer",
              ["ad"] = "@comment.outer",
              ["id"] = "@comment.inner",
              ["am"] = "@call.outer",
              ["im"] = "@call.inner",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
          lsp_interop = {
            enable = true,
            peek_definition_code = {
              ["<Leader>Df"] = "@function.outer",
              ["<Leader>DF"] = "@class.outer",
            },
          },
        },
        rainbow = {
          enable = true,
        },
        endwise = {
          enable = true,
        },
      }
    end,
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
