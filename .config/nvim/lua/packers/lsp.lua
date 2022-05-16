local function ts(plugin)
  plugin.event = { "BufNewFile", "BufRead" }
  plugin.wants = { "nvim-treesitter" }
  return plugin
end

return {
  {
    "https://github.com/williamboman/nvim-lsp-installer",
    module = { "nvim-lsp-installer" },
  },

  { -- {{{ nvim-lspconfig
    "neovim/nvim-lspconfig",
    event = { "FocusLost", "CursorHold" },
    ft = {
      "sh",
      "c",
      "cpp",
      "css",
      "dockerfile",
      "html",
      "php",
      "python",
      "ruby",
      "swift",
      "teal",
      "terraform",
      "typescript",
      "javascript",
      "vim",
      "yaml",
      "vue",
    },
    wants = {
      "nvim-lsp-installer",
      -- needs these plugins to setup capabilities
      "cmp-nvim-lsp",
    },
    config = function()
      require("nvim-lsp-installer").setup {}
      local border = require("utils.lsp").border

      vim.cmd [[
        sign define LspDiagnosticsSignError text=● texthl=LspDiagnosticsDefaultError linehl= numhl=
        sign define LspDiagnosticsSignWarning text=○ texthl=LspDiagnosticsDefaultWarning linehl= numhl=
        sign define LspDiagnosticsSignInformation text=■ texthl=LspDiagnosticsDefaultInformation linehl= numhl=
        sign define LspDiagnosticsSignHint text=□ texthl=LspDiagnosticsDefaultHint linehl= numhl=
        hi DiagnosticError guifg=#bf616a
        hi DiagnosticWarn guifg=#D08770
        hi DiagnosticInfo guifg=#8fbcbb
        hi DiagnosticHint guifg=#4c566a
        hi DiagnosticUnderlineError guisp=#bf616a gui=undercurl
        hi DiagnosticUnderlineWarn guisp=#d08770 gui=undercurl
        hi DiagnosticUnderlineInfo guisp=#8fbcbb gui=undercurl
        hi DiagnosticUnderlineHint guisp=#4c566a gui=undercurl
      ]]

      api.create_user_command("ShowLSPSettings", function()
        print(vim.inspect(vim.lsp.buf_get_clients()))
      end, { desc = "Show LSP settings" })

      api.create_user_command("ReloadLSPSettings", function()
        vim.lsp.stop_client(vim.lsp.get_active_clients())
        vim.cmd [[edit]]
      end, { desc = "Reload LSP settings" })

      vim.cmd [[
        hi LspBorderTop guifg=#5d9794 guibg=#2e3440
        hi LspBorderLeft guifg=#5d9794 guibg=#3b4252
        hi LspBorderRight guifg=#5d9794 guibg=#3b4252
        hi LspBorderBottom guifg=#5d9794 guibg=#2e3440
      ]]

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        virtual_text = true,
        signs = true,
      })
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = border }
      )

      local lsp = require "lspconfig"
      local util = require "lspconfig.util"
      local function is_git_root(p)
        return util.path.is_dir(p) and util.path.exists(util.path.join(p, ".git"))
      end

      local function is_deno_dir(p)
        local base = p:gsub([[.*/]], "")
        for _, r in ipairs {
          [[^deno]],
          [[^ddc]],
          [[^cmp%-look$]],
          [[^neco%-vim$]],
          [[^git%-vines$]],
          [[^murus$]],
          [[^skkeleton$]],
        } do
          if base:match(r) then
            return true
          end
        end
        return false
      end

      local function is_deno_file()
        local shebang = api.buf_get_lines(0, 0, 1, false)
        return #shebang == 1 and shebang[1]:match "^#!.*deno" and true or false
      end

      local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
      local home_dir = function(p)
        return loop.os_homedir() .. (p or "")
      end
      local iterm2_dir = function(p)
        return home_dir "/.config/iterm2/AppSupport/iterm2env-72/versions/3.8.6/lib/" .. (p or "")
      end

      for name, config in pairs {
        clangd = {},
        cssls = {},
        dockerls = {},
        html = {},
        intelephense = {},
        metals = {},
        --jsonls = {},
        --perlls = {},
        solargraph = {},
        sourcekit = {},
        teal_ls = {},
        terraformls = {},
        vimls = {},
        yamlls = {},
        vuels = {},

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
          root_dir = function(startpath)
            if is_deno_file() then
              return util.path.dirname(startpath)
            end
            return util.search_ancestors(startpath, function(p)
              return is_git_root(p) and is_deno_dir(p)
            end)
          end,
          init_options = {
            lint = true,
            unstable = true,
          },
        },

        tsserver = {
          root_dir = function(startpath)
            if is_deno_file() then
              return
            end
            return util.search_ancestors(startpath, function(p)
              return is_git_root(p) and not is_deno_dir(p)
            end)
          end,
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
          },
        },

        sumneko_lua = {
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
                path = vim.split(package.path, ";"),
              },
              completion = {
                keywordSnippet = "Disable",
              },
              diagnostics = {
                enable = true,
                globals = require("utils.lsp").lua_globals,
              },
              workspace = {
                library = api.get_runtime_file("", true),
              },
              telemetry = {
                enable = false,
              },
            },
          },
          on_new_config = function(config, _)
            config.settings.Lua.workspace.library = api.get_runtime_file("", true)
          end,
        },
      } do
        if capabilities then
          config.capabilities = capabilities
        end
        config.on_attach = require("utils.lsp").on_attach
        lsp[name].setup(config)
      end
    end,
    run = function()
      local dir = fn.stdpath "cache" .. "/lspconfig"
      do
        local stat = loop.fs_stat(dir)
        if not stat then
          assert(loop.fs_mkdir(dir, 448))
        end
      end
      local file = dir .. "/updated"
      local last_updated = 0
      do
        local fd = loop.fs_open(file, "r", 438)
        if fd then
          local stat = loop.fs_fstat(fd)
          local data = loop.fs_read(fd, stat.size, 0)
          loop.fs_close(fd)
          last_updated = tonumber(data) or 0
        end
      end
      local now = os.time()
      if now - last_updated > 24 * 3600 * 7 then
        local ok = pcall(function()
          vim.cmd [[!gem install --user-install solargraph]]
          vim.cmd(
            "!brew install bash-language-server gopls efm-langserver lua-language-server terraform-ls typescript"
              .. " && brew upgrade bash-language-server gopls efm-langserver lua-language-server terraform-ls typescript"
          )
          vim.cmd [[!brew uninstall vint; brew install vint --HEAD]]
          vim.cmd [[!luarocks install luacheck tl]]
          vim.cmd [[!luarocks install --dev teal-language-server]]
          vim.cmd(
            "!npm i --force -g dockerfile-language-server-nodejs intelephense pyright"
              .. " typescript-language-server vim-language-server vls vscode-langservers-extracted"
              .. " yaml-language-server"
          )
          vim.cmd [[!cpanm App::efm_perl]]

          -- These are needed for formatter.nvim
          vim.cmd [[!brew intsall stylua && brew upgrade stylua]]
          vim.cmd [[!go get -u github.com/segmentio/golines]]
          vim.cmd [[!go get -u mvdan.cc/gofumpt]]
          vim.cmd [[!npm i -g lua-fmt]]

          -- metals is installed by cs (coursier)
        end)

        if ok then
          local fd = loop.fs_open(file, "w", 438)
          if fd then
            loop.fs_write(fd, now, -1)
            loop.fs_close(fd)
          else
            error("cannot open the file to write: " .. file)
          end
        end
      end
    end,
  }, -- }}}

  ts { "nvim-treesitter/nvim-treesitter-refactor" },
  ts { "nvim-treesitter/nvim-treesitter-textobjects" },
  ts { "nvim-treesitter/playground" },
  ts { "romgrk/nvim-treesitter-context" },

  ts {
    "p00f/nvim-ts-rainbow",
    config = function()
      vim.cmd [[
      hi rainbowcol1 guifg=#bf616a
      hi rainbowcol2 guifg=#d08770
      hi rainbowcol3 guifg=#b48ead
      hi rainbowcol4 guifg=#ebcb8b
      hi rainbowcol5 guifg=#a3b812
      hi rainbowcol6 guifg=#81a1c1
      hi rainbowcol7 guifg=#8fbcbb
    ]]
    end,
  },

  { -- {{{ nvim-treesitter
    "nvim-treesitter/nvim-treesitter",
    event = { "BufNewFile", "BufRead" },
    config = function()
      require("nvim-treesitter.configs").setup {
        highlight = {
          enable = true,
          disable = { "perl" },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        ensure_installed = {
          "astro",
          "bash",
          "beancount",
          "bibtex",
          "c",
          "c_sharp",
          "clojure",
          "cmake",
          "comment",
          "commonlisp",
          "cooklang",
          "cpp",
          "css",
          "cuda",
          "d",
          "dart",
          "devicetree",
          "dockerfile",
          "dot",
          "eex",
          "elixir",
          "elm",
          "elvish",
          "erlang",
          "fennel",
          "fish",
          "foam",
          "fortran",
          "fusion",
          "gdscript",
          "gleam",
          "glimmer",
          "glsl",
          "go",
          "godot_resource",
          "gomod",
          "gowork",
          "graphql",
          "hack",
          "haskell",
          "hcl",
          "heex",
          --"help",
          "hjson",
          "hocon",
          "html",
          "http",
          "java",
          "javascript",
          "jsdoc",
          "json",
          "json5",
          "jsonc",
          "julia",
          "kotlin",
          "lalrpop",
          "latex",
          "ledger",
          "llvm",
          "lua",
          "make",
          "markdown",
          "ninja",
          "nix",
          "norg",
          "ocaml",
          "ocaml_interface",
          "ocamllex",
          "pascal",
          "perl",
          "php",
          -- "phpdoc",  -- TODO: It fails to compile in M1 Mac.
          "pioasm",
          "prisma",
          "pug",
          "python",
          "ql",
          "query",
          "r",
          "rasi",
          "regex",
          "rego",
          "rst",
          "ruby",
          "rust",
          "scala",
          "scheme",
          "scss",
          "slint",
          "solidity",
          "sparql",
          "supercollider",
          "surface",
          "svelte",
          "swift",
          "teal",
          "tlaplus",
          "todotxt",
          "toml",
          "tsx",
          "turtle",
          "typescript",
          "vala",
          "verilog",
          "vim",
          "vue",
          "wgsl",
          "yaml",
          "yang",
          "zig",
        },
        playground = {
          enable = true,
          disable = {},
          updatetime = 25,
          persist_queries = false,
        },
        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = { "BufWrite", "CursorHold" },
        },
        -- TODO: disable because too slow in C
        --[[
        refactor = {
          highlight_definitions = { enable = true },
          highlight_current_scope = { enable = true },
          smart_rename = {
            enable = true,
            keymaps = {
              smart_rename = 'grr',
            },
          },
          navigation = {
            enable = true,
            keymaps = {
              goto_definition = 'gnd',
              list_definition = 'gnD',
              list_definition_toc = 'gO',
              goto_next_usage = '<A-*>',
              goto_previous_usage = '<A-#>',
            },
          },
        },
        ]]
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
      }
      vim.keymap.set("n", "<Space>h", "<Cmd>TSHighlightCapturesUnderCursor<CR>")
    end,
    run = ":TSUpdate",
  }, -- }}}

  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local nls = require "null-ls"
      local helpers = require "null-ls.helpers"
      local methods = require "null-ls.methods"
      local utils = require "null-ls.utils"

      local function is_for_node(to_use)
        return function()
          local has_file = utils.make_conditional_utils().root_has_file {
            ".eslintrc",
            ".eslintrc.json",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".prettierrc",
            ".prettierrc.json",
            ".prettierrc.yaml",
            ".prettierrc.yml",
          }
          return to_use and has_file or not has_file
        end
      end

      nls.setup {
        diagnostics_format = "#{m} (#{s})",
        sources = {
          nls.builtins.code_actions.gitsigns,
          nls.builtins.code_actions.shellcheck,
          nls.builtins.completion.spell,
          nls.builtins.diagnostics.ansiblelint,
          nls.builtins.diagnostics.checkmake,
          nls.builtins.diagnostics.fish,
          nls.builtins.diagnostics.golangci_lint,
          nls.builtins.diagnostics.mypy,
          nls.builtins.diagnostics.rubocop,
          nls.builtins.diagnostics.shellcheck,
          nls.builtins.diagnostics.trail_space,
          nls.builtins.diagnostics.vint,
          nls.builtins.diagnostics.yamllint,
          nls.builtins.formatting.fish_indent,
          nls.builtins.formatting.gofmt,
          nls.builtins.formatting.gofumpt,
          nls.builtins.formatting.goimports,
          nls.builtins.formatting.golines,
          nls.builtins.formatting.rubocop,
          nls.builtins.formatting.stylua,
          nls.builtins.hover.dictionary,

          nls.builtins.diagnostics.luacheck.with {
            extra_args = {
              "--globals",
              unpack(require("utils.lsp").lua_globals),
            },
          },

          nls.builtins.diagnostics.eslint.with { runtime_condition = is_for_node(true) },

          nls.builtins.formatting.eslint.with { runtime_condition = is_for_node(true) },

          nls.builtins.formatting.deno_fmt.with { runtime_condition = is_for_node(false) },

          nls.builtins.formatting.prettier.with {
            disabled_filetypes = { "markdown" },
            runtime_condition = is_for_node(true),
          },

          nls.builtins.formatting.shfmt.with { extra_args = { "-i", "2", "-sr" } },

          nls.builtins.diagnostics.textlint.with { filetypes = { "markdown" } },

          helpers.make_builtin {
            name = "textlint_formatting",
            meta = { url = "https://example.com", description = "TODO" },
            method = methods.internal.FORMATTING,
            filetypes = { "markdown" },
            generator_opts = {
              command = "textlint",
              args = { "--fix", "$FILENAME" },
              to_temp_file = true,
            },
            factory = helpers.formatter_factory,
          },

          helpers.make_builtin {
            name = "perlcritic",
            meta = {
              url = "https://example.com",
              description = "TODO",
            },
            method = methods.internal.DIAGNOSTICS,
            filetypes = { "perl" },
            generator_opts = {
              command = "perlcritic",
              to_stdin = true,
              args = { "--severity", "1", "--verbose", "%s:%l:%c:%m (%P)\n" },
              format = "raw",
              check_exit_code = function(code)
                return code >= 1
              end,
              on_output = function(params, done)
                local output = params.output
                if not output then
                  return done()
                end

                local from_severity_numbers = { ["5"] = "w", ["4"] = "i", ["3"] = "n", ["2"] = "n", ["1"] = "n" }
                local lines = vim.tbl_map(function(line)
                  return line:gsub("Perl::Critic::Policy::", "", 1):gsub("^%d", function(severity_number)
                    return from_severity_numbers[severity_number]
                  end, 1)
                end, utils.split_at_newline(params.bufnr, output))

                local diagnostics = {}
                local qflist = vim.fn.getqflist { efm = "%t:%l:%c:%m", lines = lines }
                local severities = { w = 2, i = 3, n = 4 }

                for _, item in pairs(qflist.items) do
                  if item.valid == 1 then
                    local col = item.col > 0 and item.col - 1 or 0
                    table.insert(diagnostics, {
                      row = item.lnum,
                      col = col,
                      source = "perlcritic",
                      message = item.text,
                      severity = severities[item.type],
                    })
                  end
                end

                return done(diagnostics)
              end,
            },
            factory = helpers.generator_factory,
          },

          helpers.make_builtin {
            name = "efm-perl",
            meta = { url = "https://example.com", description = "TODO" },
            method = methods.internal.DIAGNOSTICS,
            filetypes = { "perl" },
            generator_opts = {
              command = "efm-perl",
              args = { "-f", "$FILENAME" },
              to_stdin = true,
              format = "raw",
              on_output = helpers.diagnostics.from_errorformat("%l:%m", "efm-perl"),
            },
            factory = helpers.generator_factory,
          },
        },

        --on_attach = on_attach,
        on_attach = require("utils.lsp").on_attach,
      }
    end,
  },
}

-- vim:se fdm=marker:
