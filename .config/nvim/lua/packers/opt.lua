return {
  {'wbthomason/packer.nvim', opt = true},

  -- Colorscheme {{{
  {
    'arcticicestudio/nord-vim',
    opt = true,
    setup = function()
      vim.g.nord_italic = 1
      vim.g.nord_italic_comments = 1
      vim.g.nord_underline = 1
      vim.g.nord_uniform_diff_background = 1
      vim.g.nord_uniform_status_lines = 1
      vim.g.nord_cursor_line_number_background = 1

      require'agrp'.set{
        nord_overrides = {
          {'ColorScheme', 'nord', function()
            vim.api.nvim_exec([[
              hi Comment guifg=#72809a gui=italic
              hi Delimiter guifg=#81A1C1
              hi Folded guifg=#72809a gui=NONE
              hi Identifier guifg=#8FBCBB
              hi Special guifg=#D08770
              hi Title gui=bold cterm=bold
            ]], false)

            -- for gitsigns
            vim.api.nvim_exec([[
              hi GitSignsAdd guifg=#a3be8c
              hi GitSignsChange guifg=#ebcb8b
              hi GitSignsDelete guifg=#bf616a
              hi GitSignsCurrentLineBlame guifg=#616e88
            ]], false)

            -- for visual-eof.lua
            vim.api.nvim_exec([[
              hi VisualEOL   guifg=#a3be8c
              hi VisualNoEOL guifg=#bf616a
            ]], false)

            -- Neovim specific
            vim.api.nvim_exec([[
              hi NormalFloat guifg=#d8dee9 guibg=#3b4252 blend=10
              hi FloatBorder guifg=#8fbcbb guibg=#3b4252 blend=10
              hi TSCurrentScope guibg=#313743
              hi rainbowcol1 guifg=#bf616a
              hi rainbowcol2 guifg=#d08770
              hi rainbowcol3 guifg=#b48ead
              hi rainbowcol4 guifg=#ebcb8b
              hi rainbowcol5 guifg=#a3b812
              hi rainbowcol6 guifg=#81a1c1
              hi rainbowcol7 guifg=#8fbcbb
            ]], false)
          end},
        },
      }
    end,
  },

  {
    'lifepillar/vim-solarized8',
    opt = true,
  },
  -- }}}

  -- cmd {{{
  {'cocopon/colorswatch.vim', cmd = {'ColorSwatchGenerate'}},

  {
    'cocopon/inspecthi.vim',
    cmd = {'Inspecthi', 'InspecthiShowInspector', 'InspecthiHideInspector'}
  },

  {
    'dhruvasagar/vim-table-mode',
    cmd = {'TableModeToggle'},
    setup = function()
      vim.g.table_mode_corner = '|'
      require'mappy'.nnoremap('`tm', [[<Cmd>TableModeToggle<CR>]])
    end,
  },

  {'fuenor/JpFormat.vim', cmd = {'JpFormatAll', 'JpJoinAll'}},

  {
    'rbgrouleff/bclose.vim',
    cmd = {
      'Tig',
      'TigOpenCurrentFile',
      'TigOpenProjectRootDir',
      'TigGrep',
      'TigBlame',
      'TigGrepResume',
      'TigStatus',
      'TigOpenFileWithCommit',
    },
  },

  {
    'iberianpig/tig-explorer.vim',
    after = {'bclose.vim'},
    cmd = {
      'Tig',
      'TigOpenCurrentFile',
      'TigOpenProjectRootDir',
      'TigGrep',
      'TigBlame',
      'TigGrepResume',
      'TigStatus',
      'TigOpenFileWithCommit',
    },
    setup = function()
      local m = require'mappy'
      m.nnoremap('<Leader>tT', [[<Cmd>TigOpenCurrentFile<CR>]])
      m.nnoremap('<Leader>tt', [[<Cmd>TigOpenProjectRootDir<CR>]])
      m.nnoremap('<Leader>tg', [[<Cmd>TigGrep<CR>]])
      m.nnoremap('<Leader>tr', [[<Cmd>TigGrepResume<CR>]])
      m.vnoremap('<Leader>tG', [[y<Cmd>TigGrep<Space><C-R>"<CR>]])
      m.nnoremap('<Leader>tc', [[<Cmd><C-u>:TigGrep<Space><C-R><C-W><CR>]])
      m.nnoremap('<Leader>tb', [[<Cmd>TigBlame<CR>]])
    end,
  },

  {
    'iamcco/markdown-preview.nvim',
    cmd = {'MarkdownPreview', 'MarkdownPreviewStop'},
    ft = {'markdown'},
    setup = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_open_to_the_world = 1
    end,
    run = 'cd app && yarn',
  },

  {
    'lambdalisue/vim-gista',
    cmd = {'Gista'},
    setup = function()
      vim.g['gista#command#list#enable_default_mappings'] = 0
    end,
    config = function()
      local m = require'mappy'
      require'agrp'.set{
        gista_mappings = {
          {'User', 'GistaList', function()
            -- nmap <buffer> <F5>   <Plug>(gista-update)
            -- nmap <buffer> <S-F5> <Plug>(gista-UPDATE)
            m.add_buffer_maps(function()
              m.nmap('q', [[<Plug>(gista-quit)]])
              m.nmap('<C-n>', [[<Plug>(gista-next-mode)]])
              m.nmap('<C-p>', [[<Plug>(gista-prev-mode)]])
              m.nmap('?', [[<Plug>(gista-toggle-mapping-visibility)]])
              m.nmap('<C-l>', [[<Plug>(gista-redraw)]])
              m.nmap('uu', [[<Plug>(gista-update)]])
              m.nmap('UU', [[<Plug>(gista-UPDATE)]])
              m.nmap('<Return>', [[<Plug>(gista-edit)]])
              m.nmap('ee', [[<Plug>(gista-edit)]])
              m.nmap('EE', [[<Plug>(gista-edit-right)]])
              m.nmap('tt', [[<Plug>(gista-edit-tab)]])
              m.nmap('pp', [[<Plug>(gista-edit-preview)]])
              m.nmap('ej', [[<Plug>(gista-json)]])
              m.nmap('EJ', [[<Plug>(gista-json-right)]])
              m.nmap('tj', [[<Plug>(gista-json-tab)]])
              m.nmap('pj', [[<Plug>(gista-json-preview)]])
              m.nmap('bb', [[<Plug>(gista-browse-open)]])
              m.nmap('yy', [[<Plug>(gista-browse-yank)]])
              m.nmap('rr', [[<Plug>(gista-rename)]])
              m.nmap('RR', [[<Plug>(gista-RENAME)]])
              m.nmap('df', [[<Plug>(gista-remove)]])
              m.nmap('DF', [[<Plug>(gista-REMOVE)]])
              m.nmap('dd', [[<Plug>(gista-delete)]])
              m.nmap('DD', [[<Plug>(gista-DELETE)]])
              m.nmap('++', [[<Plug>(gista-star)]])
              m.nmap('--', [[<Plug>(gista-unstar)]])
              m.nmap('ff', [[<Plug>(gista-fork)]])
              m.nmap('cc', [[<Plug>(gista-commits)]])
            end)
          end},
        },
      }

      if vim.fn.exists('g:gista_github_api_path') then
        local apinames = vim.fn['gista#client#get_available_apinames']()
        for _, n in ipairs(apinames) do
          if n == 'GHE' then
            vim.fn['gista#client#register'](n, vim.g.gista_github_api_path)
            break
          end
        end
      end
    end,
  },

  {
    'mbbill/undotree',
    cmd = {'UndotreeToggle'},
    setup = function()
      vim.g.undotree_HelpLine = 0
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_TreeNodeShape = '●'
      vim.g.undotree_WindowLayout = 2
      require'mappy'.nnoremap('<A-u>', [[<Cmd>UndotreeToggle<CR>]])
    end,
  },

  {
    'norcalli/nvim-colorizer.lua',
    cmd = {
      'ColorizerAttachToBuffer',
      'ColorizerDetachFromBuffer',
      'ColorizerReloadAllBuffers',
    },
    setup = function()
      require'mappy'.bind('n', {'silent'}, {'<A-C>', '<A-S-Ç>'}, function()
        if vim.b.colorizer_enabled then
          vim.cmd[[ColorizerDetachFromBuffer]]
          vim.b.colorizer_enabled = false
          vim.api.nvim_echo({{'colorizer.lua disabled', 'Debug'}}, true, {})
        else
          vim.cmd[[ColorizerAttachToBuffer]]
          vim.b.colorizer_enabled = true
          vim.api.nvim_echo({{'colorizer.lua enabled', 'Debug'}}, true, {})
        end
      end)
    end,
  },

  {
    'npxbr/glow.nvim',
    cmd = {'Glow', 'GlowInstall'},
  },

  {'powerman/vim-plugin-AnsiEsc', cmd = {'AnsiEsc'}},

  {
    'pwntester/octo.nvim',
    cmd = {'Octo'},
    key = {
      {'n', '<A-O>'},
    },
    setup = function() require'mappy'.nnoremap('<A-O>', ':Octo ') end,
    config = function()
      require'octo'.setup{github_hostname = vim.g.gh_e_host}
    end,
  },

  {
    'rhysd/ghpr-blame.vim',
    cmd = {'GHPRBlame'},
    config = function()
      local settings = vim.loop.os_homedir()..'/.ghpr-blame.vim'
      if vim.fn.filereadable(settings) == 1 then
        vim.cmd('source '..settings)
        -- TODO: mappings for VV
        vim.g.ghpr_show_pr_mapping = '<A-g>'
        vim.g.ghpr_show_pr_in_message = 1
      else
        vim.cmd[[echohl WarningMsg]]
        vim.cmd('file not found: '..settings)
        vim.cmd[[echohl None]]
      end
    end,
  },

  {
    'rhysd/git-messenger.vim',
    cmd = {'GitMessenger'},
    setup = function()
      vim.g.git_messenger_no_default_mappings = true
      require'mappy'.bind('n', {'<A-b>', '<A-∫>'}, [[<Cmd>GitMessenger<CR>]])
    end,
  },

  {
    'tyru/capture.vim',
    requires = {
      {'thinca/vim-prettyprint', cmd = {'PP', 'PrettyPrint'}},
    },
    cmd = {'Capture'},
  },

  {
    'tyru/open-browser.vim',
    cmd = {'OpenBrowser', 'OpenBrowserSearch'},
    keys = {'<Plug>(openbrowser-smart-search)'},
    fn = {'openbrowser#open'},
    config = function()
      require'mappy'.rbind('nv', 'g<CR>', [[<Plug>(openbrowser-smart-search)]])
    end,
  },

  {'tweekmonster/startuptime.vim', cmd = {'StartupTime'}},

  {
    'vifm/vifm.vim',
    cmd = {'EditVifm', 'VsplitVifm', 'SplitVifm', 'DiffVifm', 'TabVifm'},
    ft = {'vifm'},
  },

  {
    'vim-scripts/autodate.vim',
    cmd = {'Autodate', 'AutodateOFF', 'AutodateON'},
    setup = function()
      vim.g.autodate_format = '%FT%T%z'
      require'agrp'.set{
        Autodate = {{'BufUnload,FileWritePre,BufWritePre', '*', 'Autodate'}},
      }
    end
  },
  -- }}}

  -- event {{{
  -- TODO: use CmdlineEnter
  -- {'delphinus/vim-emacscommandline', event = {'CmdlineEnter'}},
  {'delphinus/vim-emacscommandline'},

  {
    'andersevenrud/compe-tmux',
    event = {'InsertEnter'},
  },

  {
    'hrsh7th/nvim-compe',
    event = {'InsertEnter'},
    after = {'compe-tmux'},
    config = function()
      local compe = require'compe'
      compe.setup{
        enabled = true,
        autocomplete = true,
        debug = false,
        min_length = 1,
        preselect = 'enable',
        throttle_time = 80,
        source_timeout = 200,
        incomplete_delay = 400,
        max_abbr_width = 100,
        max_kind_width = 100,
        max_menu_width = 100,
        documentation = true,

        source = {
          buffer = true,
          calc = true,
          nvim_lsp = true,
          nvim_lua = true,
          nvim_treesitter = true,
          path = true,
          spell = true,
          tags = true,
          vsnip = true,

          tmux = {
            all_panes = true,
          },
        },
      }
      compe.register_source('tmux', require'compe_tmux')

      local function t(key)
        return vim.api.nvim_replace_termcodes(key, true, true, true)
      end

      local function is_space_before()
        local c = vim.fn.col'.' - 1
        return c == 0 or vim.fn.getline'.':sub(c, c):match'%s'
      end

      local function tab_complete(direction)
        return function()
          if vim.fn.pumvisible() == 1 then
            return direction and t'<C-n>' or t'<C-p>'
          elseif is_space_before() then
            return direction and t'<Tab>' or t'<S-Tab>'
          end
          return direction and vim.fn['compe#complete']() or t'<S-Tab>'
        end
      end

      -- TODO: cannot bind Lua functions directory?
      --[[
      local m = require'mappy'
      m.bind('is', {'expr'}, '<Tab>', tab_complete(true))
      m.bind('is', {'expr'}, '<S-Tab>', tab_complete(false))
      ]]

      _G.tab_complete = tab_complete(true)
      _G.s_tab_complete = tab_complete(false)
      vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.tab_complete()', {expr = true})
      vim.api.nvim_set_keymap('s', '<Tab>', 'v:lua.tab_complete()', {expr = true})
      vim.api.nvim_set_keymap('i', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
      vim.api.nvim_set_keymap('s', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
    end,
  },

  {'itchyny/vim-cursorword', event = {'FocusLost', 'CursorHold'}},

  {
    'itchyny/vim-parenmatch',
    event = {'FocusLost', 'CursorHold'},
    setup = [[vim.g.loaded_matchparen = 1]],
    config = [[vim.fn['parenmatch#highlight']()]]
  },

  {
    'lewis6991/foldsigns.nvim',
    event = {'FocusLost', 'CursorHold'},
    config = function() require'foldsigns'.setup{} end,
  },

  {
    'lewis6991/gitsigns.nvim',
    event = {'FocusLost', 'CursorHold'},
    config = function()
      require'gitsigns'.setup{
        signs = {
          add = {hl = 'GitSignsAdd'},
          change = {hl = 'GitSignsChange'},
          delete = {hl = 'GitSignsDelete', text = '✗'},
          topdelete = {hl = 'GitSignsDelete', text = '↑'},
          changedelete = {hl = 'GitSignsChange', text = '•'},
        },
        numhl = true,
        current_line_blame = true,
        current_line_blame_delay = 10,
      }
    end,
  },

  {
    'preservim/tagbar',
    event = {'FocusLost', 'CursorHold'},
    cmd = {'TagbarToggle'},
    setup = function()
      vim.g.tagbar_autoclose = 1
      vim.g.tagbar_autofocus = 1
      vim.g.tagbar_autopreview = 1
      vim.g.tagbar_iconchars = {' ', ' '} -- 0xe5ff, 0xe5fe
      vim.g.tagbar_left = 1
      vim.g.tagbar_show_linenumbers = 1
      -- public:    ○
      -- protected: □
      -- private:   ●
      vim.g.tagbar_visibility_symbols = {
        public = '○ ', -- 0x25cb
        protected = '□ ', -- 0x25a1
        private = '● ', -- 0x25cf
      }

      require'agrp'.set{
        tagbar_window = {
          {'BufWinEnter', '*', function()
            -- TODO: vim.opt has no 'previewwindow'?
            if vim.wo.previewwindow then
              vim.opt.number = false
              vim.opt.relativenumber = false
            end
          end},
        },
      }

      require'mappy'.nmap('<C-t>', [[<Cmd>TagbarToggle<CR>]])
    end,
  },
  -- }}}

  -- ft {{{
  {'Glench/Vim-Jinja2-Syntax', ft = {'jinja'}},
  {'Vimjas/vim-python-pep8-indent', ft = {'python'}},
  {'aklt/plantuml-syntax', ft = {'plantuml'}},
  {'aliou/bats.vim', ft = {'bats'}},
  -- {'dag/vim-fish' ft = {'fish'}},
  {'blankname/vim-fish', ft = {'fish'}},
  {'c9s/perlomni.vim', ft = {'perl'}},
  {'cespare/vim-toml', ft = {'toml'}},
  {'dNitro/vim-pug-complete', ft = {'pug'}},
  {'delphinus/vim-data-section-simple', ft = {'perl'}},
  {'delphinus/vim-firestore', ft = {'firestore'}},
  {'delphinus/vim-toml-dein', ft = {'toml'}},
  {'derekwyatt/vim-scala', ft = {'scala'}},
  {'digitaltoad/vim-pug', ft = {'pug'}},
  {'dsawardekar/wordpress.vim', ft = {'php'}},

  {
    'fatih/vim-go',
    ft = {'go'},
    setup = function()
      vim.g.go_addtags_transform = 'camelcase'
      vim.g.go_alternate_mode = 'split'
      vim.g.go_auto_sameids = 1
      vim.g.go_auto_type_info = 1
      vim.g.go_autodetect_gopath = 0
      vim.g.go_code_completion_enabled = 0
      vim.g.go_def_mapping_enabled = 0
      vim.g.go_doc_keywordprg_enabled = 0
      vim.g.go_doc_popup_window = 1
      vim.g.go_fmt_command = 'goimports'
      vim.g.go_fmt_experimental = 1
      vim.g.go_fmt_fail_silently = 1
      vim.g.go_fmt_options = {gofmt = '-s'}
      vim.g.go_gocode_unimported_packages = 1
      vim.g.go_gopls_enabled = 1
      vim.g.go_gopls_complete_unimported = 1
      vim.g.go_gopls_deep_completion = 1
      vim.g.go_gopls_fuzzy_matching = 1
      vim.g.go_gopls_use_placeholders = 1
      vim.g.go_highlight_array_whitespace_error = 1
      vim.g.go_highlight_build_constraints = 1
      vim.g.go_highlight_chan_whitespace_error = 1
      vim.g.go_highlight_diagnostic_errors = 1
      vim.g.go_highlight_diagnostic_warnings = 1
      vim.g.go_highlight_extra_types = 1
      vim.g.go_highlight_fields = 1
      vim.g.go_highlight_format_strings = 1
      vim.g.go_highlight_functions = 1
      vim.g.go_highlight_function_parameters = 1
      vim.g.go_highlight_function_calls = 1
      vim.g.go_highlight_generate_tags = 1
      vim.g.go_highlight_operators = 1
      vim.g.go_highlight_space_tab_error = 1
      vim.g.go_highlight_string_spellcheck = 1
      vim.g.go_highlight_types = 1
      vim.g.go_highlight_trailing_whitespace_error = 1
      vim.g.go_highlight_variable_declarations = 1
      vim.g.go_highlight_variable_assignments = 1
      vim.g.go_metalinter_autosave = 0
      vim.g.go_metalinter_deadline = '10s'
      vim.g.go_template_use_pkg = 1
      vim.g.go_updatetime = 1
    end,
  },

  {
    'gisphm/vim-gitignore',
    ft = {'gitignore'},
    setup = function()
      require'agrp'.set{
        detect_other_ignores = {
          {'BufNewFile,BufRead', '.gcloudignore', 'setf gitignore'},
        },
      }
    end,
  },

  {'hail2u/vim-css3-syntax', ft = {'css'}},
  {'hashivim/vim-terraform', ft = {'terraform'}},
  {'isobit/vim-caddyfile', ft = {'caddyfile'}},
  {'junegunn/vader.vim', ft = {'vader'}},

  {
    'kchmck/vim-coffee-script',
    ft = {'coffee'},
    setup = function()
      require'agrp'.set{
        detect_cson = {{'BufNewFile,BufRead', '*.cson', 'setf coffee'}},
      }
    end,
  },

  {'keith/swift.vim', ft = {'swift'}},
  {'kevinhwang91/nvim-bqf', ft = {'qf'}},
  {'leafo/moonscript-vim', ft = {'moonscript'}},

  {
    'mhartington/formatter.nvim',
    ft = {'javascript', 'typescript'},
    config = function()
      local function prettier()
        return {
          exe = 'npx',
          args = {'prettier', '--stdin-filepath', vim.api.nvim_buf_get_name(0)},
          stdin = true,
        }
      end
      local function eslint()
        return {
          exe = 'npx',
          args = {'eslint', '--fix', '--stdin-filename', vim.api.nvim_buf_get_name(0)},
          stdin = true,
        }
      end
      require'formatter'.setup{
        filetype = {
          javascript = {prettier, eslint},
          typescript = {prettier, eslint},
        },
      }
      require'agrp'.set{
        formatter_on_save = {
          {'BufWritePost', '*.js,*.ts,*.jsx,*.tsx', 'FormatWrite'},
        },
      }
    end,
  },

  {'moznion/vim-cpanfile', ft = {'cpanfile'}},

  {
    'motemen/vim-syntax-hatena',
    ft = {'hatena'},
    config = [[vim.g.hatena_syntax_html = true]],
  },

  {'motemen/xslate-vim', ft = {'xslate'}},
  {'msanders/cocoa.vim', ft = {'objc'}},

  {
    'mustache/vim-mustache-handlebars',
    ft = {'mustache', 'handlebars', 'html.mustache', 'html.handlebars'},
  },

  {'neoclide/jsonc.vim', ft = {'jsonc'}},
  {'nikvdp/ejs-syntax', ft = {'ejs'}},
  {'pboettch/vim-cmake-syntax', ft = {'cmake'}},

  {
    'pearofducks/ansible-vim',
    ft = {'ansible', 'yaml.ansible'},
    config = function()
      vim.g.ansible_name_highlight = 'b'
      vim.g.ansible_extra_keywords_highlight = 1
    end,
  },

  {'posva/vim-vue', ft = {'vue'}},
  {'tmux-plugins/vim-tmux', ft = {'tmux'}},

  {
    'rhysd/vim-textobj-ruby',
    requires = {{'kana/vim-textobj-user'}},
    ft = {'ruby'},
  },

  {'rust-lang/rust.vim', ft = {'rust'}},

  {'teal-language/vim-teal', ft = {'teal'}},

  {
    'tpope/vim-endwise',
    ft = {
      'lua', 'elixir', 'ruby', 'crystal', 'sh', 'zsh', 'vb', 'vbnet', 'aspvbs',
      'vim', 'c', 'cpp', 'xdefaults', 'objc', 'matlab',
    },
  },

  {'uarun/vim-protobuf', ft = {'proto'}},

  {
    'delphinus/vim-rails',
    branch = 'feature/recognize-ridgepole',
    ft = {'ruby'},
  },

  {
    'vim-perl/vim-perl',
    ft = {'perl', 'perl6'},
    setup = function()
      vim.g.perl_include_pod = 1
      vim.g.perl_string_as_statement = 1
      vim.g.perl_sync_dist = 1000
      vim.g.perl_fold = 1
      vim.g.perl_nofold_packages = 1
      vim.g.perl_fold_anonymous_subs = 1
      vim.g.perl_sub_signatures = 1
    end,
  },

  {'vim-scripts/a.vim', ft = {'c', 'cpp'}},
  {'vim-scripts/applescript.vim', ft = {'applescript'}},
  {'vim-scripts/fontforge_script.vim', ft = {'fontforge_script'}},
  {'vim-scripts/nginx.vim', ft = {'nginx'}},
  -- }}}

  -- keys {{{
  {
    'arecarn/vim-fold-cycle',
    keys = {{'n', '<Plug>(fold-cycle-'}},
    setup = function()
      vim.g.fold_cycle_default_mapping = 0
      local m = require'mappy'
      m.rbind('n', {'<A-l>', '<A-¬>'}, [[<Plug>(fold-cycle-open)]])
      m.rbind('n', {'<A-h>', '<A-˙>'}, [[<Plug>(fold-cycle-open)]])
    end,
  },

  {
    'bfredl/nvim-miniyank',
    keys = {{'n', '<Plug>(miniyank-'}},
    setup = function()
      vim.g.miniyank_maxitems = 100
      local m = require'mappy'
      m.nmap('p', [[<Plug>(miniyank-autoput)]])
      m.nmap('P', [[<Plug>(miniyank-autoPut)]])
      m.rbind('n', {'<A-p>', '<A-π>'}, [[<Plug>(miniyank-cycle)]])
      m.rbind('n', {'<A-P>', '<A-S-∏>'}, [[<Plug>(miniyank-cycleback)]])
    end,
  },

  {
    'chikatoike/concealedyank.vim',
    keys = {{'x', '<Plug>(operator-concealedyank)'}},
    setup = function()
      require'mappy'.xmap('Y', [[<Plug>(operator-concealedyank)]])
    end
  },

  -- Add a space in the closing paren to enable to use folding
  {'delphinus/vim-tmux-copy', keys = {{'n', '<A-[>'}, {'n', '<A-“>'}} },

  {
    'inkarkat/vim-LineJuggler',
    requires = {
      {'inkarkat/vim-ingo-library'},
      {'vim-repeat'},
      {'vim-scripts/visualrepeat'},
    },
    keys = {
      '[d',
      ']d',
      '[E',
      ']E',
      '[e',
      ']e',
      '[f',
      ']f',
      '[<Space>',
      ']<Space>',
    },
  },

  {
    'junegunn/vim-easy-align',
    keys = {{'v', '<Plug>(EasyAlign)'}},
    setup = function()
      require'mappy'.vmap('<CR>', '<Plug>(EasyAlign)')

      vim.g.easy_align_delimiters = {
        ['>'] = { pattern = [[>>\|=>\|>]] },
        ['/'] = { pattern = [[//\+\|/\*\|\*/]], ignore_groups = {'String'} },
        ['#'] = {
          pattern = [[#\+]],
          ignore_groups = {'String'},
          delimiter_align = 'l',
        },
        [']'] = {
            pattern = [=[[[\]]]=],
            left_margin = 0,
            right_margin = 0,
            stick_to_left = 0
        },
        [')'] = {
            pattern = '[()]',
            left_margin = 0,
            right_margin = 0,
            stick_to_left = 0
          },
        ['d'] = {
            pattern = [[ \(\S\+\s*[;=]\)\@=]],
            left_margin = 0,
            right_margin = 0
          }
        }
    end
  },

  {
    --'phaazon/hop.nvim',
    'delphinus/hop.nvim',
    branch = 'feature/migemo',
    keys = {
      {'n', [[']]},
      {'v', [[']]},
      {'n', 's'},
      {'v', 's'},
    },
    config = function()
      local hop = require'hop'
      hop.setup{
        keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB',
        extend_visual = true,
        use_migemo = true,
      }
      local direction = require'hop.hint'.HintDirection
      local m = require'mappy'
      m.bind('nv', [['w]], hop.hint_words)
      m.bind('nv', [['/]], hop.hint_patterns)
      m.bind('nv', [['s]], hop.hint_char1)
      m.bind('nv', [[s]], hop.hint_char2)
      m.bind('nv', [['j]], function()
        hop.hint_lines{direction = direction.AFTER_CURSOR}
      end)
      m.bind('nv', [['k]], function()
        hop.hint_lines{direction = direction.BEFORE_CURSOR}
      end)
      if vim.opt.background:get() == 'dark' then
        vim.api.nvim_exec([[
          hi HopNextKey guifg=#bf616a
          hi HopNextKey1 guifg=#88c0d0
          hi HopNextKey2 guifg=#5e81ac
        ]], false)
      end
    end,
  },

  {
    'ruifm/gitlinker.nvim',
    keys = {
      {'n', 'gc'},
      {'v', 'gc'},
    },
    requires = {'nvim-lua/plenary.nvim'},
    config = function()
      local actions = require'gitlinker.actions'
      require'gitlinker'.setup{
        opts = {
          add_current_line_on_normal_mode = false,
          action_callback = function(url)
            actions.copy_to_clipboard(url)
            actions.open_in_browser(url)
          end,
        },
        callbacks= {
          [vim.g.gh_e_host] = require"gitlinker.hosts".get_github_type_url,
        },
        mappings = 'gc',
      }
    end,
  },

  {
    't9md/vim-quickhl',
    keys = {
      {'n', '<Plug>(quickhl-'},
      {'x', '<Plug>(quickhl-'},
    },
    setup = function()
      local m = require'mappy'
      m.rbind('nx', '<Space>m', [[<Plug>(quickhl-manual-this)]])
      m.rbind('nx', '<Space>t', [[<Plug>(quickhl-manual-toggle)]])
      m.rbind('nx', '<Space>M', [[<Plug>(quickhl-manual-reset)]])
    end,
  },

  {
    'thinca/vim-visualstar',
    keys = {{'x', '<Plug>(visualstar-'}},
    setup = function()
      vim.g.visualstar_no_default_key_mappings = 1
      require'mappy'.xmap({'unique'}, '*', [[<Plug>(visualstar-*)]])
    end,
  },

  {
    'tyru/columnskip.vim',
    keys = {
      {'n', '<Plug>(columnskip:'},
      {'x', '<Plug>(columnskip:'},
      {'o', '<Plug>(columnskip:'},
    },
    setup = function()
      local m = require'mappy'
      m.rbind('nxo', '[j', [[<Plug>(columnskip:nonblank:next)]])
      m.rbind('nxo', '[k', [[<Plug>(columnskip:nonblank:prev)]])
      m.rbind('nxo', ']j', [[<Plug>(columnskip:first-nonblank:next)]])
      m.rbind('nxo', ']k', [[<Plug>(columnskip:first-nonblank:prev)]])
    end,
  },
  -- }}}

  -- func {{{
  {
    'rhysd/committia.vim',
    fn = {'committia#open'},
    setup = function()
      -- Re-implement plugin/comittia.vim in Lua
      vim.g.loaded_committia = true
      local m = require'mappy'
      require'agrp'.set{
        ['plugin-committia'] = {
          {'BufReadPost', 'COMMIT_EDITMSG,MERGE_MSG', function()
            if vim.opt.filetype:get() == 'gitcommit'
              and vim.fn.has'vim_starting' == 1
              and vim.fn.exists'b:committia_opened' == 0 then
              function _G.committia_hook_edit_open(info)
                if info.vcs == 'git' and vim.fn.getline(1) == '' then
                  vim.cmd[[startinsert]]
                end
                m.add_buffer_maps(function()
                  m.rbind('i', {'<A-d>', '<A-∂>'}, [[<Plug>(committia-scroll-diff-down-half)]])
                  m.imap('<A-u>', [[<Plug>(committia-scroll-diff-up-half)]])
                end)
              end
              vim.g.committia_hooks = vim.empty_dict()
              vim.api.nvim_exec([[
                function! g:committia_hooks.edit_open(info)
                  call luaeval('committia_hook_edit_open(_A)', a:info)
                endfunction
              ]], false)
              vim.fn['committia#open']'git'
            end
          end},
        },
      }
    end,
  },

  {'sainnhe/artify.vim', fn = {'artify#convert'}},
  {'vim-jp/vital.vim', fn = {'vital#vital#new'}},
  -- }}}

  -- module {{{
  {
    'numToStr/FTerm.nvim',
    module = {'FTerm'},
    setup = function()
      local loaded
      require'mappy'.bind('nt', {'<A-c>', '<A-ç>'}, function()
        if not loaded then
          require'FTerm'.setup{
            cmd = vim.opt.shell:get(),
            border = {
              --[[
              {'╭', 'WinBorderTop'},
              {'─', 'WinBorderTop'},
              {' ', 'WinBorderTransparent'},
              {' ', 'WinBorderTransparent'},
              {' ', 'WinBorderTransparent'},
              {' ', 'WinBorderTransparent'},
              {' ', 'WinBorderTransparent'},
              {'│', 'WinBorderLeft'},
              ]]
              --[[
              {'█', 'WinBorderLight'},
              {'▀', 'WinBorderLight'},
              {'▀', 'WinBorderLight'},
              {'█', 'WinBorderDark'},
              {'▄', 'WinBorderLight'},
              {'▄', 'WinBorderLight'},
              {'█', 'WinBorderLight'},
              {'█', 'WinBorderLight'},
              ]]
              --[[
              {'▟', 'WinBorderLight'},
              {'▀', 'WinBorderLight'},
              {'▀', 'WinBorderLight'},
              {'▙', 'WinBorderDark'},
              {'█', 'WinBorderDark'},
              {'▛', 'WinBorderDark'},
              {'▄', 'WinBorderDark'},
              {'▜', 'WinBorderLight'},
              {'█', 'WinBorderLight'},
              ]]
              --[[
              {'╭', 'WinBorderTop'},
              {'─', 'WinBorderTop'},
              {'╮', 'WinBorderTop'},
              {'│', 'WinBorderRight'},
              {'╯', 'WinBorderBottom'},
              {'─', 'WinBorderBottom'},
              {'╰', 'WinBorderLeft'},
              {'│', 'WinBorderLeft'},
              {'⣠', 'WinBorderTop'},
              {'⣤', 'WinBorderTop'},
              {'⣄', 'WinBorderTop'},
              {'⣿', 'WinBorderRight'},
              {'⠋', 'WinBorderBottom'},
              {'⠛', 'WinBorderBottom'},
              {'⠙', 'WinBorderLeft'},
              {'⣿', 'WinBorderLeft'},
              ]]
              {'⣀', 'WinBorderTop'},
              {'⣀', 'WinBorderTop'},
              {'⣀', 'WinBorderTop'},
              {'⢸', 'WinBorderRight'},
              {'⠉', 'WinBorderBottom'},
              {'⠉', 'WinBorderBottom'},
              {'⠉', 'WinBorderBottom'},
              {'⡇', 'WinBorderLeft'},
            },
          }
          loaded = true
        end
        require'FTerm'.toggle()
      end)
    end,
    config = function()
      vim.api.nvim_exec([[
        hi WinBorderTop guifg=#ebf5f5 blend=30
        hi WinBorderLeft guifg=#c2dddc blend=30
        hi WinBorderRight guifg=#8fbcba blend=30
        hi WinBorderBottom guifg=#5d9794 blend=30
        hi WinBorderLight guifg=#c2dddc guibg=#5d9794 blend=30
        hi WinBorderDark guifg=#5d9794 guibg=#c2dddc blend=30
        hi WinBorderTransparent guibg=#111a2c
      ]], false)
    end,
  },
  -- }}}

  -- temporarily
  {
    'easymotion/vim-easymotion',
    keys = {
      {'n', [[\\s]]},
    },
    setup = function()
      vim.g.EasyMotion_use_migemo = 1
    end,
    config = function()
      require'mappy'.nmap([[\\s]], '<Plug>(easymotion-s2)')
    end,
  },
}

-- vim:se fdm=marker:
