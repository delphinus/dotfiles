return {
  {'LumaKernel/ddc-registers-words', event = {'InsertEnter'}},
  {'delphinus/ddc-tmux', event = {'InsertEnter'}},
  {'delphinus/ddc-ctags', event = {'InsertEnter'}},
  {'delphinus/ddc-treesitter', event = {'InsertEnter'}},
  {'Shougo/ddc-around', event = {'InsertEnter'}},
  {'Shougo/ddc-cmdline-history', event = {'InsertEnter'}},
  {'Shougo/ddc-converter_remove_overlap', event = {'InsertEnter'}},
  {'Shougo/ddc-line', event = {'InsertEnter'}},
  {'Shougo/ddc-matcher_head', event = {'InsertEnter'}},
  --{'Shougo/ddc-nextword', event = {'InsertEnter'}},
  {'Shougo/ddc-nvim-lsp', event = {'InsertEnter'}},
  {'Shougo/ddc-rg', event = {'InsertEnter'}},
  {'Shougo/ddc-sorter_rank', event = {'InsertEnter'}},
  {'Shougo/neco-vim', event = {'InsertEnter'}},
  {'matsui54/ddc-buffer', event = {'InsertEnter'}},
  {'matsui54/ddc-converter_truncate', event = {'InsertEnter'}},
  --{'matsui54/ddc-filter_editdistance', event = {'InsertEnter'}},
  {'octaltree/cmp-look', event = {'InsertEnter'}},
  {'tani/ddc-fuzzy', event = {'InsertEnter'}},
  {'tani/ddc-git', event = {'InsertEnter'}},
  {'tani/ddc-oldfiles', event = {'InsertEnter'}},
  {'tani/ddc-path', event = {'InsertEnter'}},
  {'vim-denops/denops.vim', event = {'InsertEnter'}},

  {
    'Shougo/echodoc.vim',
    event = {'InsertEnter'},
    setup = function()
      vim.g['echodoc#enable_at_startup'] = 1
      vim.g['echodoc#type'] = 'virtual_lines'
    end,
  },

  {
    'Shougo/pum.vim',
    event = {'InsertEnter'},
    config = function()
      vim.fn['pum#set_option']{
        winblend = 10,
      }
    end,
  },

  {
    'matsui54/denops-popup-preview.vim',
    event = {'InsertEnter'},
    after = {'denops.vim'},
    setup = function()
      vim.g.popup_preview_config = {
        winblend = 10,
      }
    end,
    config = function()
      require'packer'.loader('denops.vim')
      vim.fn['popup_preview#enable']()
    end,
  },

  {
    'ncm2/float-preview.nvim',
    event = {'InsertEnter'},
    config = function()
      vim.g['float_preview#docked'] = 1
    end,
  },

  {
    'vim-skk/skkeleton',
    event = {'InsertEnter'},
    requires = {
      {'vim-denops/denops.vim', event = {'InsertEnter'}},
      {
        'delphinus/skkeleton_indicator.nvim',
        event = {'InsertEnter'},
        config = function()
          vim.api.nvim_exec([[
            hi SkkeletonIndicatorEiji guifg=#88c0d0 guibg=#2e3440 gui=bold
            hi SkkeletonIndicatorHira guifg=#2e3440 guibg=#a3be8c gui=bold
            hi SkkeletonIndicatorKata guifg=#2e3440 guibg=#ebcb8b gui=bold
            hi SkkeletonIndicatorHankata guifg=#2e3440 guibg=#b48ead gui=bold
          ]], false)
          require'skkeleton_indicator'.setup()
        end,
      },
    },
    after = {
      'denops.vim',
    },
    config = function()
      local function home(path)
        return vim.loop.os_homedir()..path
      end
      vim.fn['skkeleton#config']{
        globalJisyo = home'/Library/Application Support/AquaSKK/SKK-JISYO.L',
        userJisyo = home'/Library/Application Support/AquaSKK/skk-jisyo.utf8',
        markerHenkan = '□',
        eggLikeNewline = true,
        useSkkServer = true,
        immediatelyCancel = false,
      }
      vim.fn['skkeleton#register_kanatable']('rom', {
        ['('] = {'（', ''},
        [')'] = {'）', ''},
        ['z '] = {'　', ''},
        ['Q'] = 'henkanPoint',
      })
      vim.fn['ddc#custom#patch_global']{
        sourceOptions = {
          skkeleton = {
            mark = 'SKK',
            matchers = {'skkeleton'},
            sorters = {},
            minAutoCompleteLength = 2,
          },
        },
      }
      local m = require'mappy'
      m.rbind('icl', '<C-j>', '<Plug>(skkeleton-enable)')
      -- Use these mappings in Karabiner-Elements
      m.rbind('icl', '<C-0>', '<Plug>(skkeleton-enable)')
      m.rbind('icl', '<C-1>', '<Plug>(skkeleton-disable)')
      local prev_buffer_config
      require'agrp'.set{
        skkeleton_callbacks = {
          {'User', 'skkeleton-enable-pre', function()
            vim.fn['pum#close']()
            prev_buffer_config = vim.fn['ddc#custom#get_buffer']()
            -- TODO: ddc-skkeleton does not support pum.vim now.
            vim.fn['ddc#custom#patch_buffer']{
              completionMenu = 'native',
              sources = {'skkeleton'},
            }
          end},
          {'User', 'skkeleton-disable-pre', function()
            vim.fn['ddc#custom#set_buffer'](prev_buffer_config)
          end},
        },
      }
    end,
  },

  {
    'Shougo/ddc.vim',
    event = {'InsertEnter'},
    --keys = {{'n', ':'}},
    fn = {
      'ddc#custom#get_buffer',
      'ddc#custom#patch_global',
    },
    -- TODO: disable cmdline completion temporarily
    --[=[
    setup = function()
      -- TODO: rewrite with using Lua
      vim.cmd[[
        "nnoremap :       <Cmd>lua __enable_ddc_cmdline()<CR>:
        nnoremap :       <Cmd>call CommandlinePre()<CR>:

        function! CommandlinePre() abort
          " Overwrite sources
          let g:prev_buffer_config = ddc#custom#get_buffer()
          echo g:prev_buffer_config
          call ddc#custom#patch_buffer('sources', ['cmdline-history', 'necovim', 'around'])

          autocmd CmdlineLeave * ++once call CommandlinePost()

          " Enable command line completion
          call ddc#enable_cmdline_completion()
        endfunction
        function! CommandlinePost() abort
          " Restore sources
          call ddc#custom#set_buffer(g:prev_buffer_config)
        endfunction
      ]]
    end,
    ]=]

    after = {
      'cmp-look',
      'ddc-around',
      'ddc-buffer',
      'ddc-cmdline-history',
      'ddc-converter_remove_overlap',
      'ddc-converter_truncate',
      'ddc-ctags',
      'ddc-fuzzy',
      'ddc-git',
      'ddc-line',
      'ddc-matcher_head',
      'ddc-nvim-lsp',
      'ddc-oldfiles',
      'ddc-path',
      'ddc-registers-words',
      'ddc-rg',
      'ddc-sorter_rank',
      'ddc-tmux',
      'ddc-treesitter',
      'denops-popup-preview.vim',
      'denops.vim',
      'echodoc.vim',
      'float-preview.nvim',
      'neco-vim',
      'pum.vim',
    },

    config = function()
      vim.fn['ddc#custom#patch_global']{
        autoCompleteEvents = {
          'InsertEnter',
          'TextChangedI',
          'TextChangedP',
          'CmdlineChanged',
        },
        backspaceCompletion = true,
        completionMenu = 'pum.vim',
        --keywordPattern = [[[_\w\d][-_\w\d]*]],
        --keywordPattern = [=[[-_\s\w\d]*]=],
        sources = {
          'nvim-lsp',
          'tmux',
          'ctags',
          'rg',
          'around',
          'buffer',
          'line',
          'treesitter',
          'registers-words',
          --'nextword',
          'look',
        },
        sourceOptions = {
          _ = {
            ignoreCase = true,
            matchers = {'matcher_fuzzy'},
            sorters = {'sorter_fuzzy'},
            converters = {'converter_remove_overlap', 'converter_truncate', 'converter_fuzzy'},
          },
          around = {mark = 'A'},
          buffer = {mark = 'B'},
          ['cmdline-history'] = {mark = 'H'},
          ctags = {mark = 'C'},
          file = {
            mark = 'F',
            isVolatile = true,
            forceCompletionPattern = [[\S/\S*]],
          },
          git = {mark = 'G'},
          line = {mark = 'LN'},
          look = {mark = 'LK', maxCandidates = 20},
          necovim = {mark = 'V'},
          --nextword = {mark = 'X'},
          ['nvim-lsp'] = {
            mark = 'L',
            forceCompletionPattern = [[\.\w*|:\w*|->\w*]],
          },
          oldfiles = {mark = 'O'},
          path = {mark = 'P', cmd = {'fd', '--max-depth', '5'}},
          ['registers-words'] = {mark = 'R'},
          rg = {mark = 'RG', minAutoCompleteLength = 4},
          treesitter = {mark = 'TS'},
          tmux = {mark = 'T'},
        },
        sourceParams = {
          around = {maxSize = 500},
          buffer = {requireSameFiletype = false},
          ['nvim-lsp'] = {maxSize = 500},
        },
        filterParams = {
          converter_fuzzy = { hlGroup = 'Question' },
          converter_truncate = {
            maxAbbrWidth = 20,
            maxInfoWidth = 80,
            maxKindWidth = 10,
            maxMenuWidth = 20,
            ellipsis = '……',
          },
        },
      }
      vim.fn['ddc#custom#patch_filetype']({'lua', 'vim'}, {
        sources = {
          'nvim-lsp',
          'tmux',
          'ctags',
          'rg',
          'necovim',
          'around',
          'buffer',
          'line',
          'treesitter',
          'registers-words',
          --'nextword',
          'look',
        },
        filterParams = {
          converter_truncate = {
            maxAbbrWidth = 80,
          },
        },
      })
      require'agrp'.set{
        ddc_ready = {
          {'User', 'DenopsReady', vim.fn['ddc#enable']},
        },
      }
      local m = require'mappy'
      --[=[
      m.bind('ci', {'expr'}, '<Tab>',   [[pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' : '<Tab>']])
      m.bind('ci', {'expr'}, '<S-Tab>', [[pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' : '<S-Tab>']])
      m.bind('ci', {'expr'}, '<C-n>',   [[pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' : '<C-n>']])
      m.bind('ci', {'expr'}, '<C-p>',   [[pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' : '<C-p>']])
      m.bind('ci', '<C-y>', vim.fn['pum#map#confirm'])
      m.bind('ci', '<C-e>', vim.fn['pum#map#cancel'])
      ]=]
      m.inoremap({'expr'}, '<Tab>',   [[pum#visible() ? ]]..
        [['<Cmd>call pum#map#insert_relative(+1)<CR>' : ]]..
        [[(col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ? ]]..
        [['<Tab>' : ddc#manual_complete()]])
      m.inoremap({'expr'}, '<S-Tab>', [[pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' : '<S-Tab>']])
      m.inoremap({'expr'}, '<C-n>',   [[pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' : '<C-n>']])
      m.inoremap({'expr'}, '<C-p>',   [[pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' : '<C-p>']])
      m.inoremap('<C-y>', vim.fn['pum#map#confirm'])
      m.inoremap('<C-e>', vim.fn['pum#map#cancel'])
      --vim.g['denops#debug'] = 1
    end,
  },
}
