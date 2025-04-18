local fn, uv, api = require("core.utils").globals()
local palette = require "core.utils.palette"

local function ts(plugin)
  plugin.event = { "BufNewFile", "BufRead" }
  return plugin
end

return {
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "williamboman/mason.nvim" },

  { "Bilal2453/luvit-meta" },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = { "justinsgithub/wezterm-types" },
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
    event = { "BufReadPre" },

    init = function()
      palette "lspconfig" {
        nord = function(colors)
          api.set_hl(0, "DiagnosticError", { fg = colors.red })
          api.set_hl(0, "DiagnosticWarn", { fg = colors.orange })
          api.set_hl(0, "DiagnosticInfo", { fg = colors.bright_cyan })
          api.set_hl(0, "DiagnosticHint", { fg = colors.nord3_bright })
          api.set_hl(0, "DiagnosticUnderlineError", { sp = colors.red, undercurl = true })
          api.set_hl(0, "DiagnosticUnderlineWarn", { sp = colors.orange, undercurl = true })
          api.set_hl(0, "DiagnosticUnderlineInfo", { sp = colors.bright_cyan, undercurl = true })
          api.set_hl(0, "DiagnosticUnderlineHint", { sp = colors.nord3_bright, undercurl = true })
          api.set_hl(0, "LspBorderTop", { fg = colors.border, bg = colors.dark_black })
          api.set_hl(0, "LspBorderLeft", { fg = colors.border, bg = colors.black })
          api.set_hl(0, "LspBorderRight", { fg = colors.border, bg = colors.black })
          api.set_hl(0, "LspBorderBottom", { fg = colors.border, bg = colors.dark_black })
        end,
      }
    end,

    config = function()
      api.create_autocmd("LspAttach", {
        desc = "Enable LSP feature in my lualine",
        group = api.create_augroup("enable-lualine-lsp", {}),
        once = true,
        callback = function()
          require("core.utils.lualine").is_lsp_available = true
        end,
      })

      api.create_autocmd("LspAttach", {
        desc = "Call the default onAttach func",
        group = api.create_augroup("common-lsp-on-attach", {}),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          require("core.utils.lsp").on_attach(client, bufnr)
        end,
      })

      require("mason").setup {
        ui = { height = 0.8, border = "rounded" },
        max_concurrent_installers = 12,
        registries = {
          "file:~/.config/nvim/mason",
          "github:mason-org/mason-registry",
        },
      }
      vim.diagnostic.config {
        float = false,
        signs = function(_, b)
          ---@diagnostic disable-next-line: return-type-mismatch
          return vim.bo[b].filetype ~= "markdown"
              and {
                text = {
                  [vim.diagnostic.severity.ERROR] = "●",
                  [vim.diagnostic.severity.WARN] = "○",
                  [vim.diagnostic.severity.INFO] = "■",
                  [vim.diagnostic.severity.HINT] = "□",
                },
              }
            or false
        end,
        virtual_text = false,
        virtual_lines = {
          format = function(diagnostic)
            return ("%s [%s]"):format(diagnostic.message, diagnostic.source)
          end,
        },
      }

      api.create_user_command("ShowLSPSettings", function()
        vim.notify(vim.inspect(vim.lsp.get_clients()))
      end, { desc = "Show LSP settings" })

      api.create_user_command("ReloadLSPSettings", function()
        vim.lsp.stop_client(vim.lsp.get_clients(), true)
        vim.cmd.edit()
      end, { desc = "Reload LSP settings" })

      local lsp = require "lspconfig"
      local home_dir = function(p)
        return uv.os_homedir() .. (p or "")
      end
      local iterm2_dir = function(p)
        return home_dir "/.config/iterm2/AppSupport/iterm2env-72/versions/3.8.6/lib/" .. (p or "")
      end

      local perl_env = (function()
        local filename = vim.uv.os_homedir() .. "/.1password-perl-env"
        local st, err = vim.uv.fs_stat(filename)
        if not st or err then
          vim.notify(filename .. " not found", vim.log.levels.WARN)
          return {}
        end
        local fd
        fd, err = vim.uv.fs_open(filename, "r", tonumber("644", 8))
        assert(not err, err)
        assert(fd, fd)
        local content
        content, err = vim.uv.fs_read(fd, st.size)
        assert(not err, err)
        assert(content, "content exists")
        return vim.iter(vim.gsplit(content, "\n")):fold({}, function(a, b)
          local key, value = b:match "^([^=]+)=(.*)$"
          if key and value then
            a[key] = value
          end
          return a
        end)
      end)()

      local server_configs = {
        perlnavigator = {
          settings = {
            perlnavigator = {
              perlEnv = perl_env,
              perlPath = "carmel",
              perlParams = { "exec", "perl" },
              includePaths = { "./lib", "./local/lib/perl5", "./t/lib" },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                extraPaths = {
                  home_dir(),
                  iterm2_dir "python38.zip",
                  iterm2_dir "python3.8",
                  iterm2_dir "python3.8/lib-dynload",
                  iterm2_dir "python3.8/site-packages",
                },
              },
            },
          },
        },
        denols = {
          init_options = {
            lint = true,
            unstable = true,
          },
          deno = {
            inlayHints = {
              parameterNames = { enabled = "all" },
              parameterTypes = { enabled = true },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              enumMemberValues = { enabled = true },
            },
          },
        },
        bashls = {
          filetypes = { "sh", "bash", "zsh" },
        },
        gopls = {
          settings = {
            hoverKind = "NoDocumentation",
            deepCompletion = true,
            fuzzyMatching = true,
            completeUnimported = true,
            usePlaceholders = true,
            gopls = {
              semanticTokens = true,
              analyses = { unusedparams = true },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = require("core.utils.lsp").lua_globals },
              format = { enable = false },
              hint = { enable = true, setType = true },
              codeLens = { enable = true },
              runtime = { version = "LuaJIT" },
              telemetry = { enable = false },
            },
          },
        },

        ts_ls = (function()
          local mason_registry = require "mason-registry"
          local vue_language_server_path = mason_registry.get_package("vue-language-server"):get_install_path()
            .. "/node_modules/@vue/language-server"
          return {
            init_options = {
              plugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vue_language_server_path,
                  languages = { "vue" },
                },
              },
            },
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
            javascript = {
              inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
            },
            typescript = {
              inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
            },
          }
        end)(),

        volar = {},

        rust_analyzer = {},
        vls = {},
      }

      require("mason-lspconfig").setup()
      require("mason-lspconfig").setup_handlers {
        function(name)
          local config = server_configs[name] or {}
          local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
          if ok then
            local orig = vim.lsp.protocol.make_client_capabilities()
            config.capabilities = cmp_nvim_lsp.default_capabilities(orig)
          end
          lsp[name].setup(config)
        end,
      }

      local Interval = require "core.utils.interval"
      local itvl = Interval.new("mason_tool_installer", 24 * 7 * 3600)
      local is_over = itvl:is_over()

      if is_over then
        vim.notify("Tools are old. Updating……", vim.log.levels.WARN)
      end

      local mason_tool_installer = require "mason-tool-installer"
      mason_tool_installer.setup {
        auto_update = is_over,
        ensure_installed = vim.env.LIGHT and {
          "eslint-lsp",
          "rubocop",
          "shellcheck",
          "shfmt",
          "stylua",
          "typescript-language-server",
          "vint",
        } or {
          "ansible-language-server",
          "clangd",
          "cmake-language-server",
          "css-lsp",
          "deno",
          "dockerfile-language-server",
          "dot-language-server",
          "eslint-lsp",
          "gofumpt",
          "goimports",
          "golangci-lint",
          "golines",
          "gopls",
          "intelephense",
          "jq",
          "json-lsp",
          "jsonnet-language-server",
          "lua-language-server",
          "luacheck",
          "marksman",
          "perlnavigator",
          "prettierd",
          "pyright",
          "rubocop",
          "shellcheck",
          "shfmt",
          "solargraph",
          "stylua",
          "terraform-ls",
          "typescript-language-server",
          "vim-language-server",
          "vint",
          "vue-language-server",
          "yaml-language-server",
        },
      }
      mason_tool_installer.check_install()

      if is_over then
        itvl:update()
      end

      local configs = require "lspconfig.configs"
      -- HACK: disable ideals temporarily
      -- if not configs.ideals then
      if false then
        configs.ideals = {
          default_config = {
            cmd = {
              vim.fs.normalize "~/Applications/IntelliJ IDEA Ultimate 2023.1.7.app/Contents/MacOS/idea",
              "lsp-server",
            },
            filetypes = { "java", "jproperties", "xml" },
            root_dir = lsp.util.root_pattern(".git", ".git/", "package.json"),
          },
        }
      end
      lsp.ideals.setup {}
    end,
  }, -- }}}

  {
    -- "dense-analysis/ale",
    "delphinus/ale",
    branch = "fix/consider-original-sign-config",
    event = { "FocusLost", "CursorHold", "BufReadPre", "BufWritePre" },
    config = function()
      vim.g.ale_linters_ignore = { "cspell", "javac" }
      vim.g.ale_fix_on_save = 1
      vim.g.ale_fixers = { lua = { "stylua" } }
      vim.g.ale_echo_cursor = 0
      vim.g.ale_virtualtext_cursor = 0
    end,
  },

  { "davidmh/cspell.nvim" },
  {
    "nvimtools/none-ls.nvim",
    event = { "FocusLost", "CursorHold", "BufReadPre", "BufWritePre" },

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

    run = function()
      local dir = fn.stdpath "cache" .. "/lspconfig"
      do
        local stat = uv.fs_stat(dir)
        if not stat then
          assert(uv.fs_mkdir(dir, 448))
        end
      end
      local file = dir .. "/updated"
      local last_updated = 0
      do
        local fd = uv.fs_open(file, "r", 438)
        if fd then
          local stat = assert(uv.fs_fstat(fd))
          local data = uv.fs_read(fd, stat.size, 0)
          uv.fs_close(fd)
          last_updated = tonumber(data) or 0
        end
      end
      local now = os.time()
      if now - last_updated > 24 * 3600 * 7 then
        local ok = pcall(require("core.utils.lsp").update_tools)
        if ok then
          local fd = uv.fs_open(file, "w", 438)
          if fd then
            uv.fs_write(fd, string(now), -1)
            uv.fs_close(fd)
          else
            error("cannot open the file to write: " .. file)
          end
        end
      end
    end,
  },

  -- ts { "RRethy/nvim-treesitter-endwise" },
  ts { "metiulekm/nvim-treesitter-endwise" },
  ts { "nvim-treesitter/nvim-treesitter-refactor" },
  ts { "nvim-treesitter/nvim-treesitter-textobjects" },

  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufRead", "BufNewFile", "InsertEnter" },
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
    opts = true,
  },

  {
    "Chaitanyabsprip/fastaction.nvim",
    keys = {
      { "gra", '<Cmd>lua require("fastaction").code_action()<CR>', mode = { "n" } },
      { "gra", '<Cmd>lua require("fastaction").range_code_action()<CR>', mode = { "v" } },
    },
    opts = true,
  },
}
