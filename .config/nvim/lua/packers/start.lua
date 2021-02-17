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

  {
    'delphinus/characterize.nvim',
    config = function()
      require'characterize'.setup{}
    end,
  },

  {'delphinus/vim-auto-cursorline'},
  {'delphinus/vim-quickfix-height'},

  {
    'direnv/direnv.vim',
    config = function() vim.g.direnv_silent_load = 1 end,
  },

  {
    'hoob3rt/lualine.nvim',
    requires = {
      {'kyazdani42/nvim-web-devicons', opt = true},
    },
    config = function()
      local characterize = require'characterize'
      local function char_info()
        local char = characterize.cursor_char()
        local results = characterize.info_table(char)
        if #results == 0 then return 'NUL' end
        local r = results[1]
        local text = ('<%s> %s'):format(r.char, r.codepoint)
        if r.digraphs and #r.digraphs > 0 then
          text = text..', \\<C-K>'..r.digraphs[1]
          if #r.digraphs > 1 then
            text = text..', ……'
          end
        end
        return text
      end

      local lualine = require'lualine'
      lualine.options.theme = 'nord'
      lualine.separator = '❘'
      lualine.sections.lualine_c = {
        {'filename', full_path = true, shorten = true},
      }
      lualine.sections.lualine_x = {
        {char_info, separator = '❘'},
        'encoding',
        {'fileformat', right_padding = 2},
      }
      lualine.sections.lualine_y = {
         'filetype',
      }
      lualine.status()
    end,
  },

  {
    'mhinz/vim-signify',
    config = function()
      vim.g.signify_vcs_list = {'git'}
      vim.g.signify_realtime = 1
      vim.g.signify_sign_add = '✓'
      vim.g.signify_sign_delete = '✗'
      vim.g.signify_sign_delete_first_line = '↑'
      vim.g.signify_sign_change = '⤷'
      vim.g.signify_sign_changedelete = '•'

      local vimp = require'vimp'
      vimp.bind('ox', 'ic', [[<Plug>(signify-motion-inner-pending)]])
      vimp.bind('ox', 'ac', [[<Plug>(signify-motion-outer-pending)]])
    end,
  },

  {
    'tpope/vim-eunuch',
    config = function()
      vim.env.SUDO_ASKPASS = vim.loop.os_homedir()..'/git/dotfiles/bin/macos-askpass'
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

  {
    -- 'tpope/vim-unimpaired',
    'delphinus/vim-unimpaired',
    config = function()
      local vimp = require'vimp'
      vimp.nnoremap('[w', [[<Cmd>colder<CR>]])
      vimp.nnoremap(']w', [[<Cmd>cnewer<CR>]])
      vimp.nnoremap('[O', [[<Cmd>lopen<CR>]])
      vimp.nnoremap(']O', [[<Cmd>lclose<CR>]])
    end,
  },


  {'vim-jp/vimdoc-ja'},
  --{'wincent/terminus'},
  {'delphinus/terminus'},
  -- }}}

  -- Syntax {{{
  {'Glench/Vim-Jinja2-Syntax'},
  {'aklt/plantuml-syntax'},
  {'isobit/vim-caddyfile'},

  {'nikvdp/ejs-syntax'},
  {'digitaltoad/vim-pug'},
  {'motemen/xslate-vim'},
  {'moznion/vim-cpanfile'},

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
            '<Cmd>setfiletype gitignore<CR>',
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
            '<Cmd>setfiletype coffee<CR>',
          },
        },
      }
    end,
  },

  {'kevinoid/vim-jsonc'},
  {'leafo/moonscript-vim'},
  {'mustache/vim-mustache-handlebars'},

  {
    'pearofducks/ansible-vim',
    config = function()
      vim.g.ansible_name_highlight = 'b'
      vim.g.ansible_extra_keywords_highlight = 1
    end,
  },
  -- }}}

  -- vim-script {{{
  {'vim-scripts/HiColors'},

  {
    'vim-scripts/autodate.vim',
    config = [[vim.g.autodate_format = '%FT%T%z']]
  },
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
