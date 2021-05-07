return {
  'nvim-telescope/telescope.nvim',
  --'delphinus/telescope.nvim',
  --branch = 'file_browser',
  requires = {
    {'delphinus/telescope-memo.nvim', opt = true},
    {'kyazdani42/nvim-web-devicons', opt = true},
    {'nvim-lua/popup.nvim', opt = true},
    {'nvim-telescope/telescope-ghq.nvim', opt = true},
    {'nvim-telescope/telescope-github.nvim', opt = true},
    {'nvim-telescope/telescope-node-modules.nvim', opt = true},
    {'nvim-telescope/telescope-packer.nvim', opt = true},
    {'nvim-telescope/telescope-symbols.nvim', opt = true},
    {'nvim-telescope/telescope-z.nvim', opt = true},
    {'plenary.nvim'},

    {
      'nvim-telescope/telescope-frecency.nvim',
      requires = {'tami5/sql.nvim'},
      opt = true,
    },

    {
      --'nvim-telescope/telescope-fzf-writer.nvim',
      'delphinus/telescope-fzf-writer.nvim',
      branch = 'feature/use-cwd',
      opt = true,
    },
  },
  cmd = {'Telescope'},
  module = {'telescope'},
  setup = function()
    local builtin = function(name) return require'telescope.builtin'[name] end
    local extensions = function(name)
      return require'telescope'.load_extension(name)
    end
    require'mappy'.nnoremap('#', function()
      builtin'current_buffer_fuzzy_find'{}
    end)
    require'which-key'.register(
      {
        f = {
          name = '+[Telescope]',
          b = {
            function() builtin'file_browser'{cwd = '%:h'} end,
            'File Browser',
          },
          f = {function()
            -- TODO: stopgap measure
            if vim.loop.cwd() == vim.loop.os_homedir() then
              vim.api.nvim_echo({
                {
                  'find_files on $HOME is danger. Launch ghq instead.',
                  'WarningMsg',
                },
              }, true, {})
              extensions'ghq'.list{}
            -- TODO: use vim.loop.fs_stat ?
            elseif vim.fn.isdirectory(vim.loop.cwd()..'/.git') then
              extensions'ghq'.list{}
            else
              extensions'fzf_writer'.files{}
            end
          end, 'git files / find files'},
          g = {function()
            builtin'grep_string'{
              only_sort_text = true,
              search = vim.fn.input'Grep For > ',
            }
          end, 'Grep'},
          G = {
            function() builtin'grep_string'{} end,
            'Grep the word on cursor',
          },
          h = {function() builtin'help_tags'{} end, 'Help'},
          H = {function() builtin'help_tags'{lang = 'en'} end, 'Help (en)'},
          m = {function() builtin'man_pages'{sections = {'ALL'}} end, 'Man'},
          o = {function() extensions'frecency'.frecency{} end, 'Frecency'},
          p = {
            function() extensions'node_modules'.list{} end,
            'List up in node_modules',
          },
          q = {function() extensions'ghq'.list{} end, 'Ghq'},
          z = {function() extensions'z'.list{} end, 'Z'},
          [':'] = {
            function() builtin'command_history'{} end,
            'Show command history',
          },
        },
        m = {
          name = '+[Telescope] memo',
          m = {function() extensions'memo'.list{} end, 'Memo'},
          g = {
            function()
              extensions'memo'.grep_string{
                only_sort_text = true,
                search = vim.fn.input'Memo Grep For >',
              }
            end,
            'Grep memo',
          },
        },
        s = {
          name = '+[Telescope] LSP',
          r = {function() builtin'lsp_references'{} end, 'Show references'},
          d = {
            function() builtin'lsp_document_symbols'{} end,
            'Show document symbols',
          },
          w = {
            function() builtin'lsp_workspace_symbols'{} end,
            'Show workspace symbols',
          },
          c = {function() builtin'lsp_code_actions'{} end, 'Show code actions'},
        },
        g = {
          name = '+[Telescope] Git',
          c = {function() builtin'git_commits'{} end, 'Commits'},
          b = {function() builtin'git_bcommits'{} end, 'Commits for buffer'},
          r = {function() builtin'git_branches'{} end, 'Branches'},
          s = {function() builtin'git_status'{} end, 'Status'},
        },
      },
      {prefix = '<Leader>'}
    )
  end,
  config = function()
    for _, name in pairs{
      'nvim-web-devicons',
      'popup.nvim',
      'sql.nvim',
      'telescope-frecency.nvim',
      'telescope-fzf-writer.nvim',
      'telescope-ghq.nvim',
      'telescope-github.nvim',
      'telescope-memo.nvim',
      'telescope-node-modules.nvim',
      'telescope-packer.nvim',
      'telescope-symbols.nvim',
      'telescope-z.nvim',
    } do
      vim.cmd('packadd '..name)
    end

    local actions = require'telescope.actions'
    local telescope = require'telescope'
    local extensions = function(name)
      return require'telescope'.load_extension(name)
    end

    local run_find_files = function(prompt_bufnr)
      local selection = actions.get_selected_entry()
      actions.close(prompt_bufnr)
      extensions'fzf_writer'.files{cwd = selection.value}
    end

    local run_live_grep = function(prompt_bufnr)
      local selection = actions.get_selected_entry()
      if vim.fn.isdirectory(selection.value) == 1 then
        actions.close(prompt_bufnr)
        extensions'fzf_writer'.staged_grep{cwd = selection.value}
      else
        vim.api.nvim_echo({{'This is not a directory.', 'WarningMsg'}}, true, {})
      end
    end

    local preview_scroll = function(direction)
      return function(prompt_bufnr)
        actions.get_current_picker(prompt_bufnr).previewer:scroll_fn(direction)
      end
    end

    telescope.setup{
      defaults = {
        mappings = {
          i = {
            ['<C-a>'] = run_find_files,
            ['<C-c>'] = actions.close,
            ['<C-g>'] = run_live_grep,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-s>'] = actions.select_horizontal,
            ['<C-n>'] = actions.select_horizontal,
            ['<C-d>'] = preview_scroll(3),
            ['<C-u>'] = preview_scroll(-3),
            ['<C-f>'] = preview_scroll(30),
            ['<C-b>'] = preview_scroll(-30),
          },
          n = {
            ['<C-a>'] = run_find_files,
            ['<C-c>'] = actions.close,
            ['<C-g>'] = run_live_grep,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-s>'] = actions.select_horizontal,
            ['<C-n>'] = actions.select_horizontal,
            ['<C-d>'] = preview_scroll(3),
            ['<C-u>'] = preview_scroll(-3),
          },
        },
        vimgrep_arguments = {
          'pt',
          '--nocolor',
          '--nogroup',
          '--column',
          '--smart-case',
          '--hidden',
        },
        winblend = 10,
        file_sorter = require'telescope.sorters'.get_fzy_sorter,
      },
      extensions = {
        frecency = {
          show_scores = true,
          show_unindexed = false,
          ignore_patterns = {'/.git/'},
          workspaces = {
            vimrc = vim.loop.os_homedir()..'/git/github.com/delphinus/dotfiles/.vim',
          },
        },
      },
    }
    -- TODO: how to use this?
    -- telescope.load_extension'packer'

    -- for telescope-frecency
    vim.api.nvim_exec([[
      hi link TelescopeBufferLoaded String
      hi link TelescopePathSeparator None
      hi link TelescopeFrecencyScores TelescopeResultsIdentifier
      hi link TelescopeQueryFilter Type
    ]], false)
  end,
}
