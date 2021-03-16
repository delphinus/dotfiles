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

      require'augroups'.set{
        nord_overrides = {
          {'ColorScheme', 'nord', function()
            vim.api.nvim_exec([[
              hi Comment guifg=#CDD0BB gui=italic
              hi CursorLine guibg=#313743
              hi Delimiter guifg=#81A1C1
              hi DeniteFilter guifg=#D8DEE9 guibg=#183203 ctermfg=NONE ctermbg=0 gui=NONE
              hi FloatPreview guifg=#D8DEE9 guibg=#183203 ctermfg=NONE ctermbg=0 gui=NONE
              hi FloatPreviewTransparent guifg=#183203 guibg=#183203 ctermfg=NONE ctermbg=0 gui=NONE
              hi Folded guifg=#D08770 gui=NONE
              hi Identifier guifg=#8FBCBB
              hi NormalFloat guifg=#D8DEE9 guibg=#0B1900 ctermfg=NONE ctermbg=0 gui=NONE
              hi Special guifg=#D08770
              hi Title gui=bold cterm=bold
              hi FloatermBorder gui=bold guifg=#5e81ac
            ]], false)

            -- for gitsigns
            vim.api.nvim_exec([[
              hi GitSignsAdd guifg=#a3be8c
              hi GitSignsChange guifg=#ebcb8b
              hi GitSignsDelete guifg=#bf616a
            ]], false)

            -- for visual-eof.lua
            vim.api.nvim_exec([[
              hi VisualEOL   guifg=#a3be8c
              hi VisualNoEOL guifg=#bf616a
            ]], false)

            -- LSP diagnostics
            vim.api.nvim_exec([[
              hi LspDiagnosticsDefaultError guifg=#bf616a guibg=#52050c gui=bold
              hi LspDiagnosticsFloatingError guifg=#bf616a guibg=NONE gui=bold
              hi LspDiagnosticsUnderlineError guifg=#bf616a guibg=NONE gui=underline
              hi LspDiagnosticsDefaultHint guifg=#a3be8c guibg=#456c26
              hi LspDiagnosticsFloatingHint guifg=#a3be8c guibg=NONE
              hi LspDiagnosticsUnderlineHint guifg=#a3be8c guibg=NONE
              hi LspDiagnosticsDefaultInformation guifg=#5e81ac guibg=#153b68
              hi LspDiagnosticsFloatingInformation guifg=#5e81ac guibg=NONE
              hi LspDiagnosticsUnderlineInformation guifg=#5e81ac guibg=NONE gui=underline
              hi LspDiagnosticsDefaultWarning guifg=#ebcb8b guibg=#432d00
              hi LspDiagnosticsFloatingWarning guifg=#ebcb8b guibg=NONE
              hi LspDiagnosticsUnderlineWarning guifg=#ebcb8b guibg=NONE gui=underline
              hi link LspReferenceText LspDiagnosticsDefaultInformation
              hi link LspReferenceRead LspDiagnosticsDefaultHint
              hi link LspReferenceWrite LspDiagnosticsDefaultWarning
            ]], false)

            -- for git-blame.nvim
            vim.cmd[[hi gitblame guifg=#4c566a gui=italic]]

            -- nvim-treesitter
            vim.api.nvim_exec([[
              hi TSCurrentScope guibg=#313743
              hi rainbowcol1 guifg=#bf616a
              hi rainbowcol2 guifg=#d08770
              hi rainbowcol3 guifg=#b48ead
              hi rainbowcol4 guifg=#ebcb8b
              hi rainbowcol5 guifg=#a3b812
              hi rainbowcol6 guifg=#81a1c1
              hi rainbowcol7 guifg=#8fbcbb

              hi TSConditional guifg=#88c0d0
              hi TSConstant guifg=#d8dee9 gui=bold
              hi TSConstructor guifg=#ebcb8b gui=bold
              hi TSException guifg=#88c0d0 gui=italic
              hi TSKeyword guifg=#9a6590 gui=bold
              hi TSMethod guifg=#ebcb8b
              hi TSProperty guifg=#8fbcbb gui=italic
              hi TSRepeat guifg=#88c0d0
              hi TSTypeBuiltin guifg=#81a1c1 gui=bold
              hi TSVariableBuiltin guifg=#d08770
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
      require'vimp'.nnoremap('`tm', [[<Cmd>TableModeToggle<CR>]])
    end,
  },

  {'fuenor/JpFormat.vim', cmd = {'JpFormatAll', 'JpJoinAll'}},

  {
    'iberianpig/tig-explorer.vim',
    requires = {{'rbgrouleff/bclose.vim'}},
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
      local vimp = require'vimp'
      vimp.nnoremap('<Leader>tT', [[<Cmd>TigOpenCurrentFile<CR>]])
      vimp.nnoremap('<Leader>tt', [[<Cmd>TigOpenProjectRootDir<CR>]])
      vimp.nnoremap('<Leader>tg', [[<Cmd>TigGrep<CR>]])
      vimp.nnoremap('<Leader>tr', [[<Cmd>TigGrepResume<CR>]])
      vimp.vnoremap('<Leader>tG', [[y<Cmd>TigGrep<Space><C-R>"<CR>]])
      vimp.nnoremap('<Leader>tc', [[<Cmd><C-u>:TigGrep<Space><C-R><C-W><CR>]])
      vimp.nnoremap('<Leader>tb', [[<Cmd>TigBlame<CR>]])
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
      local vimp = require'vimp'
      require'augroups'.set{
        gista_mappings = {
          {'User', 'GistaList', function()
            -- nmap <buffer> <F5>   <Plug>(gista-update)
            -- nmap <buffer> <S-F5> <Plug>(gista-UPDATE)
            vimp.add_buffer_maps(function()
              vimp.nmap('q', [[<Plug>(gista-quit)]])
              vimp.nmap('<C-n>', [[<Plug>(gista-next-mode)]])
              vimp.nmap('<C-p>', [[<Plug>(gista-prev-mode)]])
              vimp.nmap('?', [[<Plug>(gista-toggle-mapping-visibility)]])
              vimp.nmap('<C-l>', [[<Plug>(gista-redraw)]])
              vimp.nmap('uu', [[<Plug>(gista-update)]])
              vimp.nmap('UU', [[<Plug>(gista-UPDATE)]])
              vimp.nmap('<Return>', [[<Plug>(gista-edit)]])
              vimp.nmap('ee', [[<Plug>(gista-edit)]])
              vimp.nmap('EE', [[<Plug>(gista-edit-right)]])
              vimp.nmap('tt', [[<Plug>(gista-edit-tab)]])
              vimp.nmap('pp', [[<Plug>(gista-edit-preview)]])
              vimp.nmap('ej', [[<Plug>(gista-json)]])
              vimp.nmap('EJ', [[<Plug>(gista-json-right)]])
              vimp.nmap('tj', [[<Plug>(gista-json-tab)]])
              vimp.nmap('pj', [[<Plug>(gista-json-preview)]])
              vimp.nmap('bb', [[<Plug>(gista-browse-open)]])
              vimp.nmap('yy', [[<Plug>(gista-browse-yank)]])
              vimp.nmap('rr', [[<Plug>(gista-rename)]])
              vimp.nmap('RR', [[<Plug>(gista-RENAME)]])
              vimp.nmap('df', [[<Plug>(gista-remove)]])
              vimp.nmap('DF', [[<Plug>(gista-REMOVE)]])
              vimp.nmap('dd', [[<Plug>(gista-delete)]])
              vimp.nmap('DD', [[<Plug>(gista-DELETE)]])
              vimp.nmap('++', [[<Plug>(gista-star)]])
              vimp.nmap('--', [[<Plug>(gista-unstar)]])
              vimp.nmap('ff', [[<Plug>(gista-fork)]])
              vimp.nmap('cc', [[<Plug>(gista-commits)]])
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
      require'vimp'.nnoremap('<A-u>', [[<Cmd>UndotreeToggle<CR>]])
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
      vimp.bind('n', {'silent'}, {'<A-C>', '<A-S-Ç>'}, function()
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
    run = [[:GlowInstall]],
  },

  {'powerman/vim-plugin-AnsiEsc', cmd = {'AnsiEsc'}},

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
      vimp.bind('n', {'<A-b>', '<A-∫>'}, [[<Cmd>GitMessenger<CR>]])
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
      require'vimp'.rbind('nv', 'g<CR>', [[<Plug>(openbrowser-smart-search)]])
    end,
  },

  {'tweekmonster/startuptime.vim', cmd = {'StartupTime'}},

  {
    'vifm/vifm.vim',
    cmd = {'EditVifm', 'VsplitVifm', 'SplitVifm', 'DiffVifm', 'TabVifm'},
    ft = {'vifm'},
  },

  {
    'voldikss/vim-floaterm',
    cmd = {
      'FloatermNew', 'FloatermPrev', 'FloatermNext',
      'FloatermToggle', 'FloatermInfo',
    },
    setup = function()
      vim.g.floaterm_borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'}
      vim.g.floaterm_open_command = 'split'
      vim.g.floaterm_position = 'center'
      local vimp = require'vimp'
      vimp.tnoremap('<BS><C-n>', [[<C-\><C-n>]])
      vimp.nnoremap([[<C-\><C-n>]], [[<Cmd>FloatermToggle<CR>]])
      vimp.nnoremap('<BS><C-n>', [[<Cmd>FloatermToggle<CR>]])
      vimp.bind('nt', {'<A-c>', '<A-ç>'}, [[<Cmd>FloatermToggle<CR>]])
      vimp.bind('nt', '<A-n>', [[<Cmd>FloatermNew<CR>]])
      vimp.bind('nt', {'<A-f>', '<A-ƒ>'}, [[<Cmd>FloatermNext<CR>]])
    end,
  },
  -- }}}

  -- event {{{
  -- TODO: use CmdlineEnter
  -- {'delphinus/vim-emacscommandline', event = {'CmdlineEnter'}},
  {'delphinus/vim-emacscommandline'},

  {'itchyny/vim-cursorword', event = {'FocusLost', 'CursorHold'}},

  {
    'itchyny/vim-parenmatch',
    event = {'FocusLost', 'CursorHold'},
    setup = [[vim.g.loaded_matchparen = 1]],
    config = [[vim.fn['parenmatch#highlight']()]]
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

      require'augroups'.set{
        tagbar_window = {
          {'BufWinEnter', '*', function()
            if vim.wo.previewwindow == 1 then
              vim.wo.number = false
              vim.wo.relativenumber = false
            end
          end},
        },
      }

      require'vimp'.nmap('<C-t>', [[<Cmd>TagbarToggle<CR>]])
    end,
  },
  -- }}}

  -- ft {{{
  {'Vimjas/vim-python-pep8-indent', ft = {'python'}},
  {'aliou/bats.vim', ft = {'bats'}},
  {'c9s/perlomni.vim', ft = {'perl'}},
  {'cespare/vim-toml', ft = {'toml'}},
  {'dNitro/vim-pug-complete', ft = {'pug'}},
  {'delphinus/vim-data-section-simple', ft = {'perl'}},
  {'delphinus/vim-toml-dein', ft = {'toml'}},
  {'derekwyatt/vim-scala', ft = {'scala'}},
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

  {'hail2u/vim-css3-syntax', ft = {'css'}},
  {'junegunn/vader.vim', ft = {'vader'}},

  {
    'motemen/vim-syntax-hatena',
    ft = {'hatena'},
    config = [[vim.g.hatena_syntax_html = true]],
  },

  {'msanders/cocoa.vim', ft = {'objc'}},
  {'pboettch/vim-cmake-syntax', ft = {'cmake'}},
  {'posva/vim-vue', ft = {'vue'}},
  {'tmux-plugins/vim-tmux', ft = {'tmux'}},

  {
    'rhysd/vim-textobj-ruby',
    requires = {{'kana/vim-textobj-user'}},
    ft = {'ruby'},
  },

  {'rust-lang/rust.vim', ft = {'rust'}},

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
      vimp.rbind('n', {'<A-l>', '<A-¬>'}, [[<Plug>(fold-cycle-open)]])
      vimp.rbind('n', {'<A-h>', '<A-˙>'}, [[<Plug>(fold-cycle-open)]])
    end,
  },

  {
    'bfredl/nvim-miniyank',
    keys = {{'n', '<Plug>(miniyank-'}},
    setup = function()
      vim.g.miniyank_maxitems = 100
      local vimp = require'vimp'
      vimp.nmap('p', [[<Plug>(miniyank-autoput)]])
      vimp.nmap('P', [[<Plug>(miniyank-autoPut)]])
      vimp.rbind('n', {'<A-p>', '<A-π>'}, [[<Plug>(miniyank-cycle)]])
      vimp.rbind('n', {'<A-P>', '<A-S-∏>'}, [[<Plug>(miniyank-cycleback)]])
    end,
  },

  {
    'chikatoike/concealedyank.vim',
    keys = {{'x', '<Plug>(operator-concealedyank)'}},
    setup = function()
      require'vimp'.xmap('Y', [[<Plug>(operator-concealedyank)]])
    end
  },

  {
    'delphinus/dwm.vim',
    branch = 'feature/disable',
    keys = {{'n', '<Plug>DWM'}},
    setup = function()
      vim.g.dwm_map_keys = 0

      require'augroups'.set{
        dwm_preview = {
          {'BufRead', '*', function()
            if vim.wo.previewwindow == 1 then vim.b.dwm_disabled = 1 end
          end},
        },
      }

      local vimp = require'vimp'
      vimp.nnoremap({'silent'}, '<Plug>DWMResetPaneWidth', function()
        local half = vim.o.columns / 2
        local width = vim.g.dwm_min_master_pane_width or 9999
        vim.g.dwm_master_pane_width = math.min(width, half)
        vim.fn.DWM_ResizeMasterPaneWidth()
      end)

      vimp.nmap('<A-CR>', [[<Plug>DWMFocus]])
      vimp.rbind('n', {'<A-r>', '<A-®>'}, [[<Plug>DWMResetPaneWidth]])
      vimp.nmap('<C-@>', [[<Plug>DWMFocus]])
      vimp.nmap('<C-Space>', [[<Plug>DWMFocus]])
      vimp.nmap('<C-c>', [[<Cmd>lua require'scrollbar'.clear()<CR><Plug>DWMClose]])
      vimp.nnoremap('<C-j>', [[<C-w>w]])
      vimp.nnoremap('<C-k>', [[<C-w>W]])
      vimp.nmap('<C-l>', [[<Plug>DWMGrowMaster]])
      vimp.nmap('<C-n>', [[<Plug>DWMNew]])
      vimp.nmap('<C-q>', [[<Plug>DWMRotateCounterclockwise]])
      vimp.nmap('<C-s>', [[<Plug>DWMRotateClockwise]])
    end,
  },

  {'delphinus/vim-tmux-copy', keys = {{'n', '<A-[>'}, {'n', '<A-“>'}}},

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
      local vimp = require'vimp'
      vimp.vmap('<CR>', '<Plug>(EasyAlign)')

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
      local vimp = require'vimp'
      vimp.bind('nv', [['w]], hop.hint_words)
      vimp.bind('nv', [['/]], hop.hint_patterns)
      vimp.bind('nv', [['s]], hop.hint_char1)
      vimp.bind('nv', [[s]], function() hop.hint_char2{verbose = true} end)
      vimp.bind('nv', [['j]], hop.hint_lines)
      vimp.bind('nv', [['k]], hop.hint_lines)
      if vim.o.background == 'dark' then
        vim.api.nvim_exec([[
          hi HopNextKey guifg=#bf616a
          hi HopNextKey1 guifg=#88c0d0
          hi HopNextKey2 guifg=#5e81ac
        ]], false)
      end
    end,
  },

  {
    't9md/vim-quickhl',
    keys = {
      {'n', '<Plug>(quickhl-'},
      {'x', '<Plug>(quickhl-'},
    },
    setup = function()
      local vimp = require'vimp'
      vimp.rbind('nx', '<Space>m', [[<Plug>(quickhl-manual-this)]])
      vimp.rbind('nx', '<Space>t', [[<Plug>(quickhl-manual-toggle)]])
      vimp.rbind('nx', '<Space>M', [[<Plug>(quickhl-manual-reset)]])
    end,
  },

  {
    'thinca/vim-fontzoom',
    -- TODO: set these mapping in GUI only?
    keys = {{'n', '<Plug>(fontzoon-'}},
    cond = [[vim.fn.has'gui' == 1]],
    setup = function()
      if vim.fn.has'gui' == 1 then
        local vimp = require'vimp'
        vimp.rbind('n', {'unique', 'silent'}, {'+', '<C-ScrollWheelUp>'}, [[<Plug>(fontzoom-larger)]])
        vimp.rbind('n', {'unique', 'silent'}, {'-', '<C-ScrollWheelDown>'}, [[<Plug>(fontzoom-smaller)]])
      end
    end,
  },

  {
    'thinca/vim-visualstar',
    keys = {{'x', '<Plug>(visualstar-'}},
    setup = function()
      vim.g.visualstar_no_default_key_mappings = 1
      require'vimp'.xmap({'unique'}, '*', [[<Plug>(visualstar-*)]])
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
      local vimp = require'vimp'
      vimp.rbind('nxo', '[j', [[<Plug>(columnskip:nonblank:next)]])
      vimp.rbind('nxo', '[k', [[<Plug>(columnskip:nonblank:prev)]])
      vimp.rbind('nxo', ']j', [[<Plug>(columnskip:first-nonblank:next)]])
      vimp.rbind('nxo', ']k', [[<Plug>(columnskip:first-nonblank:prev)]])
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
      require'augroups'.set{
        ['plugin-committia'] = {
          {'BufReadPost', 'COMMIT_EDITMSG,MERGE_MSG', function()
            if vim.bo.filetype == 'gitcommit' and vim.fn.has'vim_starting'
              and vim.fn.exists'b:committia_opened' == 0 then
              function _G.committia_hook_edit_open(info)
                if info.vcs == 'git' and vim.fn.getline(1) == '' then
                  vim.cmd[[startinsert]]
                end
                vimp.add_buffer_maps(function()
                  vimp.rbind('i', {'<A-d>', '<A-∂>'}, [[<Plug>(committia-scroll-diff-down-half)]])
                  vimp.imap('<A-u>', [[<Plug>(committia-scroll-diff-up-half)]])
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
}

-- vim:se fdm=marker:
