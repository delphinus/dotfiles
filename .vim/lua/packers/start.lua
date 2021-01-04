return {
  -- TODO: needed here?
  {'nvim-lua/plenary.nvim'},

  {'svermeulen/vimpeccable'},

  -- basic {{{
  {'airblade/vim-rooter'},

  -- TODO: https://github.com/antoinemadec/FixCursorHold.nvim
  {
    'antoinemadec/FixCursorHold.nvim',
    config = [[vim.g.cursorhold_updatetime = 100]],
  },

  {'delphinus/vim-auto-cursorline'},
  {'delphinus/vim-quickfix-height'},
  {'direnv/direnv.vim'},

  {
    'datwaft/bubbly.nvim',
    config = function()
      vim.g.bubbly_palette = {
        background = '#4c566a',
        foreground = '#88c0d0',
        black = '#2e3440',
        red = '#bf616a',
        green = '#a3be8c',
        yellow = '#ebcb8b',
        blue = '#8aa1c1',
        purple = '#b48ead',
        cyan = '#88c0d0',
        white = '#d8dee9',
        lightgrey = '#616e88',
        darkgrey = '#3b4252',
      }
    end
  },

  {
    'rhysd/committia.vim',
    opt = true,
    setup = function()
      function _G.committia_hook_edit_open(info)
        if info.vcs == 'git' and vim.fn.getline(1) == '' then
          vim.cmd[[startinsert]]
        end
        local vimp = require'vimp'
        vimp.add_buffer_maps(function()
          vimp.imap('<A-d>', [[<Plug>(committia-scroll-diff-down-half)]])
          vimp.imap('<A-u>', [[<Plug>(committia-scroll-diff-up-half)]])
        end)
      end
      vim.cmd[[let g:TempFunc = {info -> v:lua.committia_hook_edit_open(info)}]]
      vim.g.committia_hooks = vim.empty_dict()
      vim.cmd[[let g:committia_hooks.edit_open = g:TempFunc]]
      vim.g.TempFunc = nil

      -- Re-implement plugin/comittia.vim in Lua
      vim.g.loaded_committia = true
      require'augroups'.set{
        ['plugin-committia'] = {
          {'BufReadPost', 'COMMIT_EDITMSG,MERGE_MSG', function()
            if vim.bo.filetype == 'gitcommit' and vim.fn.has'vim_starting'
              and vim.fn.exists'b:committia_opened' == 0 then
              vim.cmd[[packadd committia.vim]]
              vim.fn['committia#open']'git'
            end
          end},
        },
      }
    end,
  },

  {
    'tpope/vim-eunuch',
    config = function()
      vim.env.SUDO_ASKPASS = vim.env.HOME..'/git/dotfiles/bin/macos-askpass'
    end,
  },

  {
    'tpope/vim-fugitive',
    config = function()
      local vimp = require'vimp'
      vimp.nnoremap('git', [[<Cmd>Git<CR>]])
      vimp.nnoremap('g<Space>', [[<Cmd>Git<CR>]])
      vimp.nnoremap('d<', [[<Cmd>diffget //2<CR>]])
      vimp.nnoremap('d>', [[<Cmd>diffget //3<CR>]])
      vimp.nnoremap('gs', [[<Cmd>Gstatus<CR>]])
      vimp.nnoremap('gc', [[<Cmd>Gbrowse<CR>]])
      vimp.vnoremap('gc', [[<Cmd>Gbrowse<CR>]])
    end,
  },

  {'tpope/vim-repeat'},
  {'tpope/vim-rhubarb'},
  {'vim-jp/vimdoc-ja'},
  {'wincent/terminus'},
  -- }}}

  -- Colorscheme {{{
  {
    'arcticicestudio/nord-vim',
    opt = true,
    config = function()
      vim.g.nord_italic = 1
      vim.g.nord_italic_comments = 1
      vim.g.nord_underline = 1
      vim.g.nord_uniform_diff_background = 1
      vim.g.nord_uniform_status_lines = 1
      vim.g.nord_cursor_line_number_background = 1

      require'augroups'.set{
        nord_overrides = {
          {'ColorScheme', 'nord', function()
            vim.cmd[[hi Comment guifg=#CDD0BB]]
            vim.cmd[[hi CursorLine guibg=#313743]]
            vim.cmd[[hi Delimiter guifg=#81A1C1]]
            vim.cmd[[hi DeniteFilter guifg=#D8DEE9 guibg=#183203 ctermfg=NONE ctermbg=0 gui=NONE]]
            vim.cmd[[hi FloatPreview guifg=#D8DEE9 guibg=#183203 ctermfg=NONE ctermbg=0 gui=NONE]]
            vim.cmd[[hi FloatPreviewTransparent guifg=#183203 guibg=#183203 ctermfg=NONE ctermbg=0 gui=NONE]]
            vim.cmd[[hi Folded guifg=#D08770 gui=NONE]]
            vim.cmd[[hi Identifier guifg=#8FBCBB]]
            vim.cmd[[hi NormalFloat guifg=#D8DEE9 guibg=#0B1900 ctermfg=NONE ctermbg=0 gui=NONE]]
            vim.cmd[[hi Special guifg=#D08770]]
            vim.cmd[[hi Title gui=bold cterm=bold]]

            -- for gitgutter
            vim.cmd[[hi SignifyLineAdd ctermbg=233 guibg=#122b0c]]
            vim.cmd[[hi SignifyLineChange ctermbg=236 guibg=#342e0e]]
            vim.cmd[[hi SignifyLineDelete ctermbg=235 guibg=#4e2728]]

            -- for vim-go
            -- See https://github.com/arcticicestudio/nord-vim/pull/219
            vim.cmd[[hi goDeclaration  guifg=#b48ead]]
            vim.cmd[[hi goBuiltins     guifg=#88c0d0]]
            vim.cmd[[hi goFunctionCall guifg=#5e81ac]]
            vim.cmd[[hi goVarDefs      guifg=#bf616a]]
            vim.cmd[[hi goVarAssign    guifg=#bf616a]]
            vim.cmd[[hi goVar          guifg=#b48ead]]
            vim.cmd[[hi goConst        guifg=#b48ead]]
            vim.cmd[[hi goType         guifg=#ebcb8b]]
            vim.cmd[[hi goTypeName     guifg=#ebcb8b]]
            vim.cmd[[hi goDeclType     guifg=#88c0d0]]
            vim.cmd[[hi goTypeDecl     guifg=#b48ead]]

            -- for visual-eof.lua
            vim.cmd[[hi VisualEOL   guifg=#a3be8c]]
            vim.cmd[[hi VisualNoEOL guifg=#bf616a]]

            vim.cmd[[hi GitGutterAddLineNr guifg=#a3be8c guibg=#163601 gui=bold]]
            vim.cmd[[hi GitGutterChangeDeleteLineNr guifg=#ebcb8b guibg=#432d00 gui=bold]]
            vim.cmd[[hi GitGutterChangeLineNr guifg=#ebcb8b guibg=#432d00 gui=bold]]
            vim.cmd[[hi GitGutterDeleteLineNr guifg=#bf616a guibg=#52050c gui=bold]]

            -- for ALE
            vim.cmd[[hi ALEErrorSignLineNr guifg=#bf616a guibg=#52050c gui=bold]]
            vim.cmd[[hi ALEInfoSignLineNr guifg=#5e81ac guibg=#153b68 gui=bold]]
            vim.cmd[[hi ALEStyleErrorSignLineNr guifg=#bf616a guibg=NONE gui=bold]]
            vim.cmd[[hi ALEStyleWarningSignLineNr guifg=#ebcb8b guibg=NONE gui=bold]]
            vim.cmd[[hi ALEWarningSignLineNr guifg=#ebcb8b guibg=#432d00 gui=bold]]
            vim.cmd[[hi ALEErrorSign guifg=#bf616a guibg=#52050c gui=bold]]
            vim.cmd[[hi ALEInfoSign guifg=#5e81ac guibg=#153b68 gui=bold]]
            vim.cmd[[hi ALEStyleErrorSign guifg=#bf616a guibg=NONE gui=bold]]
            vim.cmd[[hi ALEStyleWarningSign guifg=#ebcb8b guibg=NONE gui=bold]]
            vim.cmd[[hi ALEWarningSign guifg=#ebcb8b guibg=#432d00 gui=bold]]
            vim.cmd[[hi ALEVirtualTextError guifg=#bf616a guibg=#52050c gui=bold]]
            vim.cmd[[hi ALEVirtualTextInfo guifg=#5e81ac guibg=#153b68]]
            vim.cmd[[hi ALEVirtualTextStyleError guifg=#bf616a guibg=NONE]]
            vim.cmd[[hi ALEVirtualTextStyleWarning guifg=#ebcb8b guibg=NONE]]
            vim.cmd[[hi ALEVirtualTextWarning guifg=#ebcb8b guibg=#432d00]]

            -- LSP diagnostics
            vim.cmd[[hi LspDiagnosticsDefaultError guifg=#bf616a guibg=#52050c gui=bold]]
            vim.cmd[[hi LspDiagnosticsFloatingError guifg=#bf616a guibg=NONE gui=bold]]
            vim.cmd[[hi LspDiagnosticsUnderlineError guifg=#bf616a guibg=NONE gui=underline]]
            vim.cmd[[hi LspDiagnosticsDefaultHint guifg=#a3be8c guibg=#456c26]]
            vim.cmd[[hi LspDiagnosticsFloatingHint guifg=#a3be8c guibg=NONE]]
            vim.cmd[[hi LspDiagnosticsUnderlineHint guifg=#a3be8c guibg=NONE]]
            vim.cmd[[hi LspDiagnosticsDefaultInformation guifg=#5e81ac guibg=#153b68]]
            vim.cmd[[hi LspDiagnosticsFloatingInformation guifg=#5e81ac guibg=NONE]]
            vim.cmd[[hi LspDiagnosticsUnderlineInformation guifg=#5e81ac guibg=NONE gui=underline]]
            vim.cmd[[hi LspDiagnosticsDefaultWarning guifg=#ebcb8b guibg=#432d00]]
            vim.cmd[[hi LspDiagnosticsFloatingWarning guifg=#ebcb8b guibg=NONE]]
            vim.cmd[[hi LspDiagnosticsUnderlineWarning guifg=#ebcb8b guibg=NONE gui=underline]]
            vim.cmd[[hi link LspReferenceText LspDiagnosticsDefaultInformation]]
            vim.cmd[[hi link LspReferenceRead LspDiagnosticsDefaultHint]]
            vim.cmd[[hi link LspReferenceWrite LspDiagnosticsDefaultWarning]]

            -- for git-blame.nvim
            vim.cmd[[hi gitblame guifg=#4c566a gui=italic]]

            -- nvim-treesitter
            vim.cmd[[hi TSCurrentScope guibg=#313743]]
            vim.cmd[[hi rainbowcol1 guifg=#bf616a]]
            vim.cmd[[hi rainbowcol2 guifg=#d08770]]
            vim.cmd[[hi rainbowcol3 guifg=#b48ead]]
            vim.cmd[[hi rainbowcol4 guifg=#ebcb8b]]
            vim.cmd[[hi rainbowcol5 guifg=#a3b812]]
            vim.cmd[[hi rainbowcol6 guifg=#81a1c1]]
            vim.cmd[[hi rainbowcol7 guifg=#8fbcbb]]

            vim.cmd[[hi TSConditional guifg=#88c0d0]]
            vim.cmd[[hi TSConstant guifg=#d8dee9 gui=bold]]
            vim.cmd[[hi TSConstructor guifg=#ebcb8b gui=bold]]
            vim.cmd[[hi TSException guifg=#88c0d0 gui=italic]]
            vim.cmd[[hi TSKeyword guifg=#9a6590 gui=bold]]
            vim.cmd[[hi TSMethod guifg=#ebcb8b]]
            vim.cmd[[hi TSProperty guifg=#8fbcbb gui=italic]]
            vim.cmd[[hi TSRepeat guifg=#88c0d0]]
            vim.cmd[[hi TSTypeBuiltin guifg=#81a1c1 gui=bold]]
            vim.cmd[[hi TSVariableBuiltin guifg=#d08770]]
          end},
        },
      }
    end,
  },
  -- }}}

  -- Syntax {{{
  {'Glench/Vim-Jinja2-Syntax'},
  {'aklt/plantuml-syntax'},
  {'cespare/vim-toml'},
  {'delphinus/vim-toml-dein'},
  {'hail2u/vim-css3-syntax'},
  {'isobit/vim-caddyfile'},

  {
    'motemen/vim-syntax-hatena',
    config = [[vim.g.hatena_syntax_html = true]],
  },

  {'nikvdp/ejs-syntax'},

  {
    'plasticboy/vim-markdown',
    config = function()
      vim.g.vim_markdown_conceal = 0
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_new_list_item_indent = 2
    end,
  },

  {'digitaltoad/vim-pug'},
  {'isRuslan/vim-es6'},
  {'motemen/xslate-vim'},
  {'moznion/vim-cpanfile'},

  {
    'pboettch/vim-cmake-syntax',
    config = function()
      require'augroups'.set{
        cmake_syntax = {
          {
            'BufNewFile,BufRead',
            'CMake*,*.cmake.*,*.cmake',
            function() vim.bo.filetype = 'cmake' end,
          },
        },
      }
    end,
  },

  {
    'vim-perl/vim-perl',
    config = function()
      vim.g.perl_include_pod = 1
      vim.g.perl_string_as_statement = 1
      vim.g.perl_sync_dist = 1000
      vim.g.perl_fold = 1
      vim.g.perl_nofold_packages = 1
      vim.g.perl_fold_anonymous_subs = 1
      vim.g.perl_sub_signatures = 1
    end,
  },
  -- }}}

  -- Filetype {{{
  {'asciidoc/vim-asciidoc'},
  {'c9s/perlomni.vim'},
  {'dNitro/vim-pug-complete'},
  -- {'dag/vim-fish'},
  {'blankname/vim-fish'},
  {'delphinus/vim-firestore'},

  {
    'gisphm/vim-gitignore',
    config = function()
      require'augroups'.set{
        detect_other_ignores = {
          {
            'BufNewFile,BufRead',
            '.gcloudignore',
            function() vim.bo.filetype = 'gitignore' end,
          },
        },
      }
    end,
  },

  {
    'kchmck/vim-coffee-script',
    config = function()
      require'augroups'.set{
        detect_cson = {
          {
            'BufNewFile,BufRead',
            '*.cson',
            function() vim.bo.filetype = 'coffee' end,
          },
        },
      }
    end,
  },

  {'kevinoid/vim-jsonc'},
  {'jason0x43/vim-js-indent'},
  {'mustache/vim-mustache-handlebars'},

  {
    'pearofducks/ansible-vim',
    config = function()
      vim.g.ansible_name_highlight = 'b'
      vim.g.ansible_extra_keywords_highlight = 1
    end,
  },

  {'posva/vim-vue'},
  {'tmux-plugins/vim-tmux'},
  {'uarun/vim-protobuf'},
  -- }}}

  -- vim-script {{{
  {'vim-scripts/HiColors'},
  {'vim-scripts/applescript.vim'},

  {
    'vim-scripts/autodate.vim',
    config = [[vim.g.autodate_format = '%FT%T%z']]
  },

  {'vim-scripts/fontforge_script.vim'},
  {'vim-scripts/nginx.vim'},
  -- }}}

  -- lua-script {{{
  {
    'LumaKernel/nvim-visual-eof.lua',
    config = function()
      require'visual-eof'.setup{
        text_EOL = ' ',
        text_NOEOL = ' ',
        ft_ng = {
          'denite',
          'denite-filter',
          'floaterm',
          'fugitive.*',
          'git.*',
        },
      }
    end,
  },

  {
    'Xuyuanp/scrollbar.nvim',
    config = function()
      vim.g.scrollbar_shape = {
        head = '╽',
        body = '┃',
        tail = '╿',
      }
      vim.g.scrollbar_highlight = {
        head = 'Todo',
        body = 'Todo',
        tail = 'Todo',
      }
      vim.g.scrollbar_excluded_filetypes = {'denite-filter'}

      local vimp = require'vimp'
      local scrollbar = require'scrollbar'
      local augroups = require'augroups'
      local enabled = false

      vimp.map_command('ToggleScrollbar', function()
        if enabled then
          scrollbar.clear()
          augroups.set{my_scrollbar_nvim = {}}
          enabled = false
        else
          scrollbar.show()
          augroups.set{
            my_scrollbar_nvim = {
              {
                'WinEnter,FocusGained,CursorMoved,VimResized',
                '*',
                scrollbar.show,
              },
              {
                'WinLeave,FocusLost,BufLeave',
                '*',
                scrollbar.clear,
              },
            },
          }
          enabled = true
        end
      end)

      -- TODO: deal with :only in this plugin
      vimp.nnoremap('<C-w>o', function()
        vim.cmd[[only]]
        scrollbar.show()
      end)

      -- start scrollbar
      vim.cmd[[ToggleScrollbar]]
    end,
  },

  {'f-person/git-blame.nvim'},
  -- }}}

  -- }}}
}
