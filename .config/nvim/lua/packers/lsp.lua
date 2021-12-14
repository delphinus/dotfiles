return {
  { -- {{{ nvim-lspconfig
    'neovim/nvim-lspconfig',
    event = {'FocusLost', 'CursorHold'},
    ft = {
      'sh', 'c', 'cpp', 'css', 'dockerfile', 'html', 'php', 'python', 'ruby',
      'swift', 'terraform', 'typescript', 'javascript', 'vim', 'yaml', 'vue'
    },
    config = function()
      local m = require'mappy'

      vim.cmd[[
        sign define LspDiagnosticsSignError text=● texthl=LspDiagnosticsDefaultError linehl= numhl=
        sign define LspDiagnosticsSignWarning text=○ texthl=LspDiagnosticsDefaultWarning linehl= numhl=
        sign define LspDiagnosticsSignInformation text=■ texthl=LspDiagnosticsDefaultInformation linehl= numhl=
        sign define LspDiagnosticsSignHint text=□ texthl=LspDiagnosticsDefaultHint linehl= numhl=
      ]]

      function _G.ShowLSPSettings()
        print(vim.inspect(vim.lsp.buf_get_clients()))
      end
      function _G.ReloadLSPSettings()
        vim.lsp.stop_client(vim.lsp.get_active_clients())
        vim.cmd[[edit]]
      end

      vim.cmd[[
        hi LspBorderTop guifg=#5d9794 guibg=#2e3440
        hi LspBorderLeft guifg=#5d9794 guibg=#3b4252
        hi LspBorderRight guifg=#5d9794 guibg=#3b4252
        hi LspBorderBottom guifg=#5d9794 guibg=#2e3440
      ]]
      local border = {
        {'⣀', 'LspBorderTop'},
        {'⣀', 'LspBorderTop'},
        {'⣀', 'LspBorderTop'},
        {'⢸', 'LspBorderRight'},
        {'⠉', 'LspBorderBottom'},
        {'⠉', 'LspBorderBottom'},
        {'⠉', 'LspBorderBottom'},
        {'⡇', 'LspBorderLeft'},
      }

      local lsp_on_attach = function(diag_maps_only)
        return function(client, bufnr)
          print(('LSP started: bufnr = %d'):format(bufnr))
          --require'completion'.on_attach()

          if client.config.flags then
            client.config.flags.allow_incremental_sync = true
          end

          api.buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

          -- ignore errors when executed multi times
          m.add_buffer_maps(function()
            m.bind('n', {'<A-J>', '<A-S-Ô>'}, function()
              vim.diagnostic.goto_next{
                popup_opts = {border = border},
              }
            end)
            m.bind('n', {'<A-K>', '<A-S->'}, function()
              vim.diagnostic.goto_prev{
                popup_opts = {border = border},
              }
            end)
            m.nnoremap('<Space>E', function()
              if vim.b.lsp_diagnostics_disabled then
                vim.lsp.diagnostic.enable()
              else
                vim.lsp.diagnostic.disable()
              end
              vim.b.lsp_diagnostics_disabled = not vim.b.lsp_diagnostics_disabled
            end)
            m.nnoremap('<Space>e', function()
              vim.lsp.diagnostic.show_line_diagnostics{border = border}
            end)
            m.nnoremap('<Space>q', vim.lsp.diagnostic.set_loclist)
            if not diag_maps_only then
              m.nnoremap('K', vim.lsp.buf.hover)
              m.nnoremap('1gD', vim.lsp.buf.type_definition)
              if vim.opt.filetype:get() ~= 'help' then
                m.nnoremap('<C-]>', vim.lsp.buf.definition)
                m.nnoremap('<C-w><C-]>', function()
                  vim.cmd[[split]]
                  vim.lsp.buf.definition()
                end)
              end
              m.nnoremap('<C-x><C-k>', vim.lsp.buf.signature_help)
              m.nnoremap('g0', vim.lsp.buf.document_symbol)
              m.nnoremap('g=', vim.lsp.buf.formatting)
              m.nnoremap('gA', vim.lsp.buf.code_action)
              m.nnoremap('gD', vim.lsp.buf.implementation)
              m.nnoremap('gR', vim.lsp.buf.rename)
              m.nnoremap('gW', vim.lsp.buf.workspace_symbol)
              m.nnoremap('gd', vim.lsp.buf.declaration)
              m.nnoremap('gli', vim.lsp.buf.incoming_calls)
              m.nnoremap('glo', vim.lsp.buf.outgoing_calls)
              m.nnoremap('gr', vim.lsp.buf.references)
            end
          end)
        end
      end

      vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
          underline = true,
          virtual_text = true,
          signs = true,
        }
      )
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
        vim.lsp.handlers.hover, {border = border}
      )
      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {border = border}
      )

      local lsp = require'lspconfig'
      local util = require'lspconfig.util'
      local function is_git_root(p)
        return util.path.is_dir(p) and util.path.exists(util.path.join(p, '.git'))
      end
      local function is_deno_dir(p)
        local base = p:gsub([[.*/]], '')
        for _, r in ipairs{
          [[^deno]],
          [[^ddc]],
          [[^cmp%-look$]],
          [[^neco%-vim$]],
          [[^git%-vines$]],
          [[^murus$]],
          [[^skkeleton$]],
        } do
          if base:match(r) then return true end
        end
        return false
      end

      for name, config in pairs{
        clangd = {on_attach = lsp_on_attach()},
        cssls = {on_attach = lsp_on_attach()},
        dockerls = {on_attach = lsp_on_attach()},
        html = {on_attach = lsp_on_attach()},
        intelephense = {on_attach = lsp_on_attach()},
        metals = {on_attach = lsp_on_attach()},
        --jsonls = {on_attach = lsp_on_attach()},
        --perlls = {on_attach = lsp_on_attach()},
        pyright = {on_attach = lsp_on_attach()},
        solargraph = {on_attach = lsp_on_attach()},
        sourcekit = {on_attach = lsp_on_attach()},
        terraformls = {on_attach = lsp_on_attach()},
        vimls = {on_attach = lsp_on_attach()},
        yamlls = {on_attach = lsp_on_attach()},
        vuels = {on_attach = lsp_on_attach()},

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
          filetypes = {'sh', 'bash', 'zsh'},
        },

        efm = {
          filetypes = {
            'bash', 'css', 'csv', 'dockerfile', 'eruby', 'html', 'javascript',
            'json', 'lua', 'make', 'markdown', 'perl', 'php', 'python', 'rst',
            'sh', 'typescript', 'vim', 'yaml', 'zsh',
          },
          on_attach = lsp_on_attach(true),
          init_options = {
            documentFormatting = true,
            hover = true,
            documentSymbol = true,
            codeAction = true,
            completion = true
          }
        },

        gopls = {
          on_attach = lsp_on_attach(),
          settings = {
            hoverKind = 'NoDocumentation',
            deepCompletion = true,
            fuzzyMatching = true,
            completeUnimported = true,
            usePlaceholders = true,
          },
        },

        sumneko_lua = (function()
          local sumneko_root_path = loop.os_homedir()..'/git/github.com/sumneko/lua-language-server'
          local sumneko_binary = ('%s/bin/%s/lua-language-server'):format(
            sumneko_root_path,
            loop.os_uname().sysname == 'Darwin' and 'macOS' or 'Linux'
          )
          return {
            on_attach = lsp_on_attach(),
            cmd = {sumneko_binary, '-E', sumneko_root_path..'/main.lua'},
            settings = {
              Lua = {
                runtime = {
                  version = 'LuaJIT',
                  path = vim.split(package.path, ';'),
                },
                completion = {
                  keywordSnippet = 'Disable',
                },
                diagnostics = {
                  enable = true,
                  globals = {
                    'vim',
                    'packer_plugins',

                    -- for testing
                    'after_each',
                    'before_each',
                    'describe',
                    'it',

                    -- hammerspoon
                    'hs',

                    -- wrk
                    'wrk',
                    'setup',
                    'id',
                    'init',
                    'request',
                    'response',
                    'done',
                  },
                },
                workspace = {
                  library = {
                    [fn.expand'$VIMRUNTIME/lua'] = true,
                    [fn.expand'$VIMRUNTIME/lua/vim/lsp'] = true,
                    ['/Applications/Hammerspoon.app/Contents/Resources/extensions'] = true,
                  },
                },
              }
            }
          }
        end)(),

        teal = (function()
          local configs = require'lspconfig.configs'
          if not configs.teal then
            configs.teal = {
              default_config = {
                cmd = {'teal-language-server'},
                filetypes = {'teal'},
                root_dir = lsp.util.root_pattern('tlconfig.lua', '.git'),
                settings = {},
              },
            }
          end
          return {on_attach = lsp_on_attach()}
        end)(),
      } do lsp[name].setup(config) end
    end,
    run = function()
      local dir = fn.stdpath'cache'..'/lspconfig'
      do
        local stat = loop.fs_stat(dir)
        if not stat then
          assert(loop.fs_mkdir(dir, 448))
        end
      end
      local file = dir..'/updated'
      local last_updated = 0
      do
        local fd = loop.fs_open(file, 'r', 438)
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
          -- TODO: update sumneko_lua automatically
          vim.cmd[[!gem install --user-install solargraph]]
          vim.cmd('!brew install gopls efm-langserver terraform-ls typescript'
            ..' && brew upgrade gopls efm-langserver terraform-ls typescript')
          vim.cmd[[!brew uninstall vint; brew install vint --HEAD]]
          vim.cmd[[!luarocks install luacheck tl]]
          vim.cmd[[!luarocks install --dev teal-language-server]]
          vim.cmd('!npm i --force -g bash-language-server dockerfile-language-server-nodejs intelephense pyright'
            ..' typescript-language-server vim-language-server vls vscode-css-languageserver-bin'
            ..' vscode-html-languageserver-bin vscode-json-languageserver yaml-language-server')
          vim.cmd[[!source (plenv init -| psub); plenv shell system; cpanm App::efm_perl]]

          -- These are needed for formatter.nvim
          vim.cmd[[!go get -u github.com/segmentio/golines]]
          vim.cmd[[!go get -u mvdan.cc/gofumpt]]
          vim.cmd[[!npm i -g lua-fmt]]

          -- metals is installed by cs (coursier)
        end)

        if ok then
          local fd = loop.fs_open(file, 'w', 438)
          if fd then
            loop.fs_write(fd, now, -1)
            loop.fs_close(fd)
          else
            error('cannot open the file to write: '..file)
          end
        end
      end
    end,
  }, -- }}}

  --[=[
  { -- {{{ completion-nvim
    'nvim-lua/completion-nvim',
    requires = {
      {'steelsojka/completion-buffers'},
      {'nvim-treesitter/completion-treesitter'},
      {'kristijanhusak/completion-tags'},
      {'albertoCaroM/completion-tmux'},
    },
    config = function()
      local m = require'mappy'

      require'agrp'.set{
        enable_completion_nvim = {
          {'BufEnter', '*', require'completion'.on_attach},
        },
      }

      m.inoremap({'expr'}, '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
      m.inoremap({'expr'}, '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])
      m.rbind('i', {'<A-j>', '<A-∆>'}, [[<Plug>(completion_next_source)]])
      m.rbind('i', {'<A-k>', '<A-˚>'}, [[<Plug>(completion_prev_source)]])

      vim.o.completeopt = 'menuone,noinsert,noselect'
      vim.g.completion_auto_change_source = 1
      vim.g.completion_confirm_key = [[\<C-y>]]
      vim.g.completion_matching_strategy_list = {'exact', 'fuzzy'}
      vim.g.completion_chain_complete_list = {
        default = {
          {complete_items = {'lsp', 'tags'}},
          {complete_items = {'ts', 'buffers', 'tmux'}},
          {complete_items = {'path'}, triggered_only = {'/'}},
          {mode = 'omni'},
          {mode = '<C-p>'},
          {mode = '<C-n>'},
          {mode = 'keyn'},
          {mode = 'keyp'},
          {mode = 'file'},
          {mode = 'dict'},
        },
        c = {
          {complete_items = {'lsp', 'tags'}},
          {complete_items = {'buffers', 'tmux'}},
          {complete_items = {'path'}, triggered_only = {'/'}},
          {mode = 'omni'},
          {mode = '<C-p>'},
          {mode = '<C-n>'},
          {mode = 'keyn'},
          {mode = 'keyp'},
          {mode = 'file'},
          {mode = 'dict'},
        },
        -- TODO: omnifunc from vim-rhubarb is too slow
        gitcommit = {
          {complete_items = {'buffers', 'tmux'}},
          {complete_items = {'path'}, triggered_only = {'/'}},
          {mode = 'dict'},
          {mode = 'file'},
          {mode = '<C-p>'},
          {mode = '<C-n>'},
          {mode = 'keyn'},
          {mode = 'keyp'},
        },
      }
    end,
  }, -- }}}
  ]=]

  {'nvim-treesitter/nvim-treesitter-refactor', event = {'BufNewFile', 'BufRead'}},
  {'nvim-treesitter/nvim-treesitter-textobjects', event = {'BufNewFile', 'BufRead'}},
  {'nvim-treesitter/playground', event = {'BufNewFile', 'BufRead'}},
  {'p00f/nvim-ts-rainbow', event = {'BufNewFile', 'BufRead'}},
  {'romgrk/nvim-treesitter-context', event = {'BufNewFile', 'BufRead'}},

  { -- {{{ nvim-treesitter
    'nvim-treesitter/nvim-treesitter',
    event = {'BufNewFile', 'BufRead'},
    after = {
      'nvim-treesitter-context',
      'nvim-treesitter-refactor',
      'nvim-treesitter-textobjects',
      'nvim-ts-rainbow',
      'playground',
    },
    config = function()
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
          disable = {'perl'},
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
          },
        },
        ensure_installed = 'all',
        playground = {
          enable = true,
          disable = {},
          updatetime = 25,
          persist_queries = false,
        },
        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = {"BufWrite", "CursorHold"},
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
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['aC'] = '@class.outer',
              ['iC'] = '@class.inner',
              ['ac'] = '@conditional.outer',
              ['ic'] = '@conditional.inner',
              ['ae'] = '@block.outer',
              ['ie'] = '@block.inner',
              ['al'] = '@loop.outer',
              ['il'] = '@loop.inner',
              ['is'] = '@statement.inner',
              ['as'] = '@statement.outer',
              ['ad'] = '@comment.outer',
              ['id'] = '@comment.inner',
              ['am'] = '@call.outer',
              ['im'] = '@call.inner',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>A'] = '@parameter.inner',
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
          lsp_interop = {
            enable = true,
            peek_definition_code = {
              ['<Leader>Df'] = '@function.outer',
              ['<Leader>DF'] = '@class.outer',
            },
          },
        },
        rainbow = {
          enable = true,
        },
      }
      require'mappy'.nnoremap('<Space>h', '<Cmd>TSHighlightCapturesUnderCursor<CR>')
    end,
    run = ':TSUpdate'
  }, -- }}}
}

-- vim:se fdm=marker:
