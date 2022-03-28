return {
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
      "terraform",
      "typescript",
      "javascript",
      "vim",
      "yaml",
      "vue",
    },
    wants = {
      -- needs these plugins to setup capabilities
      "cmp-nvim-lsp",
    },
    config = function()
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

      api.add_user_command("ShowLSPSettings", function()
        print(vim.inspect(vim.lsp.buf_get_clients()))
      end, { desc = "Show LSP settings" })

      api.add_user_command("ReloadLSPSettings", function()
        vim.lsp.stop_client(vim.lsp.get_active_clients())
        vim.cmd [[edit]]
      end, { desc = "Reload LSP settings" })

      vim.cmd [[
        hi LspBorderTop guifg=#5d9794 guibg=#2e3440
        hi LspBorderLeft guifg=#5d9794 guibg=#3b4252
        hi LspBorderRight guifg=#5d9794 guibg=#3b4252
        hi LspBorderBottom guifg=#5d9794 guibg=#2e3440
      ]]
      local border = {
        { "⣀", "LspBorderTop" },
        { "⣀", "LspBorderTop" },
        { "⣀", "LspBorderTop" },
        { "⢸", "LspBorderRight" },
        { "⠉", "LspBorderBottom" },
        { "⠉", "LspBorderBottom" },
        { "⠉", "LspBorderBottom" },
        { "⡇", "LspBorderLeft" },
      }

      local lsp_on_attach = function(diag_maps_only)
        return function(client, bufnr)
          print(("LSP started: bufnr = %d"):format(bufnr))
          --require'completion'.on_attach()

          if client.config.flags then
            client.config.flags.allow_incremental_sync = true
          end

          api.buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

          -- ignore errors when executed multi times
          local function goto_next()
            vim.diagnostic.goto_next {
              popup_opts = { border = border },
            }
          end
          vim.keymap.set("n", "<A-J>", goto_next, { buffer = bufnr })
          vim.keymap.set("n", "<A-S-Ô>", goto_next, { buffer = bufnr })

          local function goto_prev()
            vim.diagnostic.goto_prev {
              popup_opts = { border = border },
            }
          end
          vim.keymap.set("n", "<A-K>", goto_prev, { buffer = bufnr })
          vim.keymap.set("n", "<A-S->", goto_prev, { buffer = bufnr })

          vim.keymap.set("n", "<Space>E", function()
            if vim.b.lsp_diagnostics_disabled then
              vim.diagnostic.enable()
            else
              vim.diagnostic.disable()
            end
            vim.b.lsp_diagnostics_disabled = not vim.b.lsp_diagnostics_disabled
          end, { buffer = bufnr })
          vim.keymap.set("n", "<Space>e", function()
            vim.diagnostic.open_float { border = border }
          end, { buffer = bufnr })
          vim.keymap.set("n", "<Space>q", vim.lsp.diagnostic.set_loclist, { buffer = bufnr })
          if not diag_maps_only then
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
            vim.keymap.set("n", "1gD", vim.lsp.buf.type_definition, { buffer = bufnr })
            if vim.opt.filetype:get() ~= "help" then
              vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, { buffer = bufnr })
              vim.keymap.set("n", "<C-w><C-]>", function()
                vim.cmd [[split]]
                vim.lsp.buf.definition()
              end, { buffer = bufnr })
            end
            vim.keymap.set("n", "<C-x><C-k>", vim.lsp.buf.signature_help, { buffer = bufnr })
            vim.keymap.set("n", "g0", vim.lsp.buf.document_symbol, { buffer = bufnr })
            vim.keymap.set("n", "g=", vim.lsp.buf.formatting, { buffer = bufnr })
            vim.keymap.set("n", "gA", vim.lsp.buf.code_action, { buffer = bufnr })
            vim.keymap.set("n", "gD", vim.lsp.buf.implementation, { buffer = bufnr })
            vim.keymap.set("n", "gR", vim.lsp.buf.rename, { buffer = bufnr })
            vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, { buffer = bufnr })
            vim.keymap.set("n", "gd", vim.lsp.buf.declaration, { buffer = bufnr })
            vim.keymap.set("n", "gli", vim.lsp.buf.incoming_calls, { buffer = bufnr })
            vim.keymap.set("n", "glo", vim.lsp.buf.outgoing_calls, { buffer = bufnr })
            vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
          end
        end
      end

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
        for _, r in
          ipairs {
            [[^deno]],
            [[^ddc]],
            [[^cmp%-look$]],
            [[^neco%-vim$]],
            [[^git%-vines$]],
            [[^murus$]],
            [[^skkeleton$]],
          }
        do
          if base:match(r) then
            return true
          end
        end
        return false
      end

      local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

      for name, config in
        pairs {
          clangd = { on_attach = lsp_on_attach() },
          cssls = { on_attach = lsp_on_attach() },
          dockerls = { on_attach = lsp_on_attach() },
          html = { on_attach = lsp_on_attach() },
          intelephense = { on_attach = lsp_on_attach() },
          metals = { on_attach = lsp_on_attach() },
          --jsonls = {on_attach = lsp_on_attach()},
          --perlls = {on_attach = lsp_on_attach()},
          pyright = { on_attach = lsp_on_attach() },
          solargraph = { on_attach = lsp_on_attach() },
          sourcekit = { on_attach = lsp_on_attach() },
          terraformls = { on_attach = lsp_on_attach() },
          vimls = { on_attach = lsp_on_attach() },
          yamlls = { on_attach = lsp_on_attach() },
          vuels = { on_attach = lsp_on_attach() },

          denols = {
            on_attach = lsp_on_attach(),
            root_dir = function(startpath)
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
            on_attach = lsp_on_attach(),
            root_dir = function(startpath)
              return util.search_ancestors(startpath, function(p)
                return is_git_root(p) and not is_deno_dir(p)
              end)
            end,
          },

          bashls = {
            on_attach = lsp_on_attach(),
            filetypes = { "sh", "bash", "zsh" },
          },

          efm = {
            filetypes = {
              "bash",
              "css",
              "csv",
              "dockerfile",
              "eruby",
              "html",
              "javascript",
              "json",
              "lua",
              "make",
              "markdown",
              "perl",
              "php",
              "python",
              "rst",
              "sh",
              "typescript",
              "vim",
              "yaml",
              "zsh",
            },
            on_attach = lsp_on_attach(true),
            init_options = {
              documentFormatting = true,
              hover = true,
              documentSymbol = true,
              codeAction = true,
              completion = true,
            },
          },

          gopls = {
            on_attach = lsp_on_attach(),
            settings = {
              hoverKind = "NoDocumentation",
              deepCompletion = true,
              fuzzyMatching = true,
              completeUnimported = true,
              usePlaceholders = true,
            },
          },

          sumneko_lua = {
            on_attach = lsp_on_attach(),
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
                  globals = {
                    "vim",
                    "packer_plugins",
                    "api",
                    "fn",
                    "loop",

                    -- for testing
                    "after_each",
                    "before_each",
                    "describe",
                    "it",

                    -- hammerspoon
                    "hs",

                    -- wrk
                    "wrk",
                    "setup",
                    "id",
                    "init",
                    "request",
                    "response",
                    "done",
                  },
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

          teal = (function()
            local configs = require "lspconfig.configs"
            if not configs.teal then
              configs.teal = {
                default_config = {
                  cmd = { "teal-language-server" },
                  filetypes = { "teal" },
                  root_dir = lsp.util.root_pattern("tlconfig.lua", ".git"),
                  settings = {},
                },
              }
            end
            return { on_attach = lsp_on_attach() }
          end)(),
        }
      do
        if capabilities then
          config.capabilities = capabilities
        end
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

  { "nvim-treesitter/nvim-treesitter-refactor", event = { "BufNewFile", "BufRead" } },
  { "nvim-treesitter/nvim-treesitter-textobjects", event = { "BufNewFile", "BufRead" } },
  { "nvim-treesitter/playground", event = { "BufNewFile", "BufRead" } },
  { "romgrk/nvim-treesitter-context", event = { "BufNewFile", "BufRead" } },

  {
    "p00f/nvim-ts-rainbow",
    event = { "BufNewFile", "BufRead" },
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
    after = {
      "nvim-treesitter-context",
      "nvim-treesitter-refactor",
      "nvim-treesitter-textobjects",
      "nvim-ts-rainbow",
      "playground",
    },
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
        ensure_installed = "all",
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
}

-- vim:se fdm=marker:
