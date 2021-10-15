return {
  -- TODO: needed here?
  {'nvim-lua/plenary.nvim'},

  -- basic {{{
  {
    'ahmedkhalf/project.nvim',
    config = function()
      require'project_nvim'.setup{
        ignore_lsp = {'bashls', 'efm', 'tsserver'},
        patterns = {'.git'},
      }
    end,
  },

  -- TODO: https://github.com/antoinemadec/FixCursorHold.nvim
  {
    'antoinemadec/FixCursorHold.nvim',
    config = [[vim.g.cursorhold_updatetime = 100]],
  },

  'delphinus/agrp.nvim',
  'delphinus/artify.nvim',
  'delphinus/mappy.nvim',

  {
    'delphinus/characterize.nvim',
    config = function() require'characterize'.setup{} end,
  },

  --[=[
  {
    'delphinus/dwm.vim',
    branch = 'feature/disable',
    setup = function()
      vim.g.dwm_map_keys = 0
    end,
    config = function()
      require'agrp'.set{
        dwm_preview = {
          {'BufRead', '*', function()
            if vim.wo.previewwindow == 1 then vim.b.dwm_disabled = 1 end
          end},
        },
      }

      local m = require'mappy'
      m.nnoremap({'silent'}, '<Plug>DWMResetPaneWidth', function()
        local half = vim.o.columns / 2
        local width = vim.g.dwm_min_master_pane_width or 9999
        vim.g.dwm_master_pane_width = math.min(width, half)
        vim.fn.DWM_ResizeMasterPaneWidth()
      end)
      m.nmap('<A-CR>', [[<Plug>DWMFocus]])
      m.rbind('n', {'<A-r>', '<A-®>'}, [[<Plug>DWMResetPaneWidth]])
      m.nmap('<C-@>', [[<Plug>DWMFocus]])
      m.nmap('<C-Space>', [[<Plug>DWMFocus]])
      m.nmap('<C-c>', [[<Cmd>lua pcall(require'scrollbar'.clear)<CR><Plug>DWMClose]])
      m.nnoremap('<C-j>', [[<C-w>w]])
      m.nnoremap('<C-k>', [[<C-w>W]])
      m.nmap('<C-l>', [[<Plug>DWMGrowMaster]])
      m.nmap('<C-n>', [[<Plug>DWMNew]])
      m.nmap('<C-q>', [[<Plug>DWMRotateCounterclockwise]])
      m.nmap('<C-s>', [[<Plug>DWMRotateClockwise]])
    end,
  },
  ]=]

  {'delphinus/vim-auto-cursorline'},
  {'delphinus/vim-quickfix-height'},

  {
    'direnv/direnv.vim',
    config = function() vim.g.direnv_silent_load = 1 end,
  },

  {'editorconfig/editorconfig-vim'},

  -- TODO: remove this when Neovim includes this
  {'lewis6991/impatient.nvim'},

  {
    'shadmansaleh/lualine.nvim',
    requires = {
      {'kyazdani42/nvim-web-devicons', opt = true},
    },
    config = function()
      require'agrp'.set{
         redraw_tabline = {
            {'CursorMoved', '*', 'redrawtabline'},
         },
      }

      local characterize = require'characterize'
      local function char_info()
        local char = characterize.cursor_char()
        local results = characterize.info_table(char)
        if #results == 0 then return 'NUL' end
        local r = results[1]
        local text = ('<%s> %s'):format(r.char, r.codepoint)
        if r.digraphs and #r.digraphs > 0 then
          text = text..', \\<C-K>'..r.digraphs[1]
        end
        if r.description ~= '<unknown>' then
          text = text..', '..r.description
        end
        return text
      end
      local monospace = function(value)
        -- TODO: Disable monospace glyphs temporarily
        return value
        --return vim.g.goneovim == 1 and value or
          --require'artify'(value, 'monospace')
      end
      local treesitter = function()
        local ok, m = pcall(require, 'nvim-treesitter')
        return ok and m.statusline{
          separator = ' » ',
          transform_fn = function(line)
            return line:gsub('%s*[%[%(%{].*$', '')
          end,
        } or ''
      end
      local skkeleton = function()
        local ok, mode = pcall(vim.fn['skkeleton#mode'])
        if not ok or mode == '' then
          vim.cmd[[hi! lualine-skkeleton guifg=#88c0d0 guibg=#2e3440 gui=bold]]
          return '英字'
        elseif mode == 'hira' then
          vim.cmd[[hi! lualine-skkeleton guifg=#2e3440 guibg=#a3be8c gui=bold]]
          return 'ひら'
        end
        vim.cmd[[hi! lualine-skkeleton guifg=#2e3440 guibg=#ebcb8b gui=bold]]
        return 'カタ'
      end
      require'lualine'.setup{
        extensions = {'quickfix'},
        options = {
          theme = 'nord',
          section_separators = '',
          component_separators = '❘',
        },
        sections = {
          lualine_a = {
            {'mode', fmt = monospace},
          },
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {},
          lualine_y = {'filetype'},
          lualine_z = {'location'},
        },
        tabline = {
          lualine_a = {},
          lualine_b = {
            {
              skkeleton,
              color = 'lualine-skkeleton',
              update_in_insert = true,
            },
            {'branch', fmt = monospace},
            {
              'diff',
              symbols = {
                added = '↑',
                modified = '→',
                removed = '↓',
              },
            },
            {
              'diagnostics',
              sources = {'nvim_lsp'},
              diagnostics_color = {
                error = '#e5989f',
                warn = '#ebcb8b',
                info = '#8ca9cd',
                hint = '#616e88',
              },
              symbols = {
                error = '●', -- U+25CF
                warn = '○', -- U+25CB
                info = '■', -- U+25A0
              },
            },
          },
          lualine_c = {
            {'filename', fmt = monospace},
            {treesitter, separator = '❘'},
          },
          lualine_x = {
            {char_info, separator = '❘'},
            'encoding',
            {'fileformat', padding = {right = 2}},
          },
          lualine_y = {},
          lualine_z = {},
        },
      }
    end,
  },

  {
    'kevinhwang91/nvim-hlslens',
    config = function()
      -- TODO: use Lua for this block
      local do_hlslens = function(map, need_count1)
        return function()
          local count1 = need_count1 and (vim.v.count1 or '1') or ''
          local ok, err = pcall(vim.cmd, 'normal! '..count1..map)
          if ok then
            require'hlslens'.start()
          else
            vim.api.nvim_err_writeln(err)
          end
        end
      end
      local m = require'mappy'
      m.nnoremap({'silent'}, 'n', do_hlslens('n', true))
      m.nnoremap({'silent'}, 'N', do_hlslens('N', true))
      m.nnoremap('g*', do_hlslens('g*', true))
      m.nnoremap('g#', do_hlslens('g#', true))
      -- Use with vim-visualstar
      m.nmap('*', [[*<Cmd>lua require('hlslens').start()<CR>]])
      -- # will be used in telescope
      -- m.nnoremap('#', do_hlslens('#', true))
    end,
  },

  {'lambdalisue/suda.vim'},

  {
    'rcarriga/nvim-notify',
    config = function()
      local stages = require'notify.stages'.fade_in_slide_out
      local orig1 = stages[1]
      stages[1] = function(state)
        local opts = orig1(state)
        opts.focusable = false
        return opts
      end
      local notify = require'notify'
      notify.setup{
        stages = stages,
      }
      vim.notify = notify
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
      local m = require'mappy'
      m.nnoremap('git', [[<Cmd>Git<CR>]])
      m.nnoremap('g<Space>', [[<Cmd>Git<CR>]])
      m.nnoremap('d<', [[<Cmd>diffget //2<CR>]])
      m.nnoremap('d>', [[<Cmd>diffget //3<CR>]])
      m.nnoremap('gs', [[<Cmd>Gstatus<CR>]])
    end,
  },

  {'tpope/vim-repeat'},
  {'tpope/vim-rhubarb'},

  {
    -- 'tpope/vim-unimpaired',
    'delphinus/vim-unimpaired',
    config = function()
      local m = require'mappy'
      m.nnoremap('[w', [[<Cmd>colder<CR>]])
      m.nnoremap(']w', [[<Cmd>cnewer<CR>]])
      m.nnoremap('[O', [[<Cmd>lopen<CR>]])
      m.nnoremap(']O', [[<Cmd>lclose<CR>]])
    end,
  },


  {'vim-jp/vimdoc-ja'},
  --{'wincent/terminus'},
  {'delphinus/terminus'},
  -- }}}

  -- vim-script {{{
  {'vim-scripts/HiColors'},
  -- }}}

  -- lua-script {{{
  {
    'LumaKernel/nvim-visual-eof.lua',
    config = function()
      require'visual-eof'.setup{
        text_EOL = ' ',
        text_NOEOL = ' ',
        ft_ng = {
          'FTerm',
          'denite',
          'denite-filter',
          'fugitive.*',
          'git.*',
          'packer',
        },
        buf_filter = function(bufnr)
          return vim.api.nvim_buf_get_option(bufnr, 'buftype') == ''
        end,
      }
    end,
  },

  {
    'delphinus/dwm.nvim',
    config = function()
      local dwm = require'dwm'
      dwm.setup{
        key_maps = false,
        master_pane_count = 1,
        master_pane_width = '60%',
      }
      dwm.map('<C-j>', '<C-w>w')
      dwm.map('<C-k>', '<C-w>W')
      dwm.map('<A-CR>', dwm.focus)
      dwm.map('<C-@>', dwm.focus)
      dwm.map('<C-Space>', dwm.focus)
      dwm.map('<C-l>', dwm.grow)
      dwm.map('<C-h>', dwm.shrink)
      dwm.map('<C-n>', dwm.new)
      dwm.map('<C-q>', dwm.rotateLeft)
      dwm.map('<C-s>', dwm.rotate)
      dwm.map('<C-c>', function()
        -- TODO: copied logic from require'scrollbar'.clear
        local state = vim.b.scrollbar_state
        if state and state.winnr then
          local ok = pcall(vim.api.nvim_win_close, state.winnr, true)
          if not ok then
            vim.api.nvim_echo({
              {'cannot found scrollbar win: '..state.winnr, 'WarningMsg'},
            }, true, {})
          end
          vim.b.scrollbar_state = {size = state.size, bufnr = state.bufnr}
        end
        dwm.close()
      end)

      require'agrp'.set{
        dwm_preview = {
          {'BufRead', '*', function()
            -- TODO: vim.opt has no 'previewwindow'?
            if vim.wo.previewwindow then vim.b.dwm_disabled = 1 end
          end},
        },
      }
    end,
  },

  {'folke/todo-comments.nvim'},
  -- }}}
}

-- vim:se fdm=marker:
