return {
  'nvim-telescope/telescope.nvim',
  requires = {
    {'delphinus/telescope-memo.nvim', opt = true},
    {'kyazdani42/nvim-web-devicons', opt = true},
    {'nvim-lua/popup.nvim', opt = true},
    {'nvim-telescope/telescope-fzf-native.nvim', opt = true, run = 'make'},
    {'nvim-telescope/telescope-ghq.nvim', opt = true},
    {'nvim-telescope/telescope-github.nvim', opt = true},
    {'nvim-telescope/telescope-node-modules.nvim', opt = true},
    {'nvim-telescope/telescope-packer.nvim', opt = true},
    {'nvim-telescope/telescope-symbols.nvim', opt = true},
    {'nvim-telescope/telescope-z.nvim', opt = true},
    {'plenary.nvim'},

    {
      'nvim-telescope/telescope-frecency.nvim',
      requires = {'tami5/sql.nvim', opt = true},
      opt = true,
    },

    {
      'nvim-telescope/telescope-smart-history.nvim',
      requires = {'tami5/sql.nvim', opt = true},
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
    local m = require'mappy'

    -- Lines
    m.nnoremap('#', function()
      builtin'current_buffer_fuzzy_find'{}
    end)

    -- Files
    m.nnoremap('<Leader>fB', function() builtin'buffers'{} end)
    m.nnoremap('<Leader>fb', function() builtin'file_browser'{cwd = '%:h'} end)
    m.nnoremap('<Leader>ff', function()
      -- TODO: stopgap measure
      if vim.loop.cwd() == vim.loop.os_homedir() then
        vim.api.nvim_echo({
          {
            'find_files on $HOME is danger. Launch file_browser instead.',
            'WarningMsg',
          },
        }, true, {})
        builtin'file_browser'{}
      -- TODO: use vim.loop.fs_stat ?
      elseif vim.fn.isdirectory(vim.loop.cwd()..'/.git') == 1 then
        builtin'git_files'{}
      else
        builtin'find_files'{hidden = true}
      end
    end)
    m.nnoremap('<Leader>fg', function()
      builtin'grep_string'{
        only_sort_text = true,
        search = vim.fn.input'Grep For ❯ ',
      }
    end)
    m.nnoremap('<Leader>f:', function() builtin'command_history'{} end)
    m.nnoremap('<Leader>fG', function() builtin'grep_string'{} end)
    m.nnoremap('<Leader>fH', function() builtin'help_tags'{lang = 'en'} end)
    m.nnoremap('<Leader>fP', function() extensions'packer'.plugins{} end)
    m.nnoremap('<Leader>fh', function() builtin'help_tags'{} end)
    m.nnoremap('<Leader>fm', function() builtin'man_pages'{sections = {'ALL'}} end)
    m.nnoremap('<Leader>fn', function() extensions'node_modules'.list{} end)
    m.nnoremap('<Leader>fo', function() extensions'frecency'.frecency{} end)
    m.nnoremap('<Leader>fp', function() extensions'projects'.projects{} end)
    m.nnoremap('<Leader>fq', function() extensions'ghq'.list{} end)
    m.nnoremap('<Leader>fz', function() extensions'z'.list{} end)

    -- Memo
    m.nnoremap('<Leader>mm', function() extensions'memo'.list{} end)
    m.nnoremap('<Leader>mg', function()
      extensions'memo'.grep_string{
        only_sort_text = true,
        search = vim.fn.input'Memo Grep For ❯ ',
      }
    end)

    -- LSP
    m.nnoremap('<Leader>sr', function() builtin'lsp_references'{} end)
    m.nnoremap('<Leader>sd', function() builtin'lsp_document_symbols'{} end)
    m.nnoremap('<Leader>sw', function() builtin'lsp_workspace_symbols'{} end)
    m.nnoremap('<Leader>sc', function() builtin'lsp_code_actions'{} end)

    -- Git
    m.nnoremap('<Leader>gc', function() builtin'git_commits'{} end)
    m.nnoremap('<Leader>gb', function() builtin'git_bcommits'{} end)
    m.nnoremap('<Leader>gr', function() builtin'git_branches'{} end)
    m.nnoremap('<Leader>gs', function() builtin'git_status'{} end)
  end,
  config = function()
    vim.api.nvim_exec([[
      packadd nvim-web-devicons
      packadd popup.nvim
      packadd sql.nvim
      packadd telescope-frecency.nvim
      packadd telescope-fzf-native.nvim
      packadd telescope-ghq.nvim
      packadd telescope-github.nvim
      packadd telescope-memo.nvim
      packadd telescope-node-modules.nvim
      packadd telescope-packer.nvim
      packadd telescope-smart-history.nvim
      packadd telescope-symbols.nvim
      packadd telescope-z.nvim
    ]], false)

    local actions = require'telescope.actions'
    local telescope = require'telescope'
    local builtin = function(name) return require'telescope.builtin'[name] end
    local extensions = function(name)
      return require'telescope'.load_extension(name)
    end
    local Path = require'plenary.path'

    local run_find_files = function(prompt_bufnr)
      local selection = actions.get_selected_entry()
      actions.close(prompt_bufnr)
      builtin'find_files'{cwd = selection.value}
    end

    local run_live_grep = function(prompt_bufnr)
      local selection = actions.get_selected_entry()
      if vim.fn.isdirectory(selection.value) == 1 then
        actions.close(prompt_bufnr)
        builtin'live_grep'{cwd = selection.value}
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
            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,
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
        history = {
          path = Path:new(vim.fn.stdpath'data', 'telescope_history.sqlite3').filename,
          limit = 100,
        },
        winblend = 10,
        prompt_prefix = '❯❯❯ ',
        selection_caret = '❯ ',
        dynamic_preview_title = true,
      },
      extensions = {
        frecency = {
          show_scores = true,
          show_unindexed = false,
          ignore_patterns = {'/.git/'},
          disable_devicons = true,
          workspaces = {
            vimrc = vim.loop.os_homedir()..'/git/github.com/delphinus/dotfiles/.vim',
          },
        },
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
      },
    }
    -- This is needed to setup telescope-fzf-native. It overrides the sorters
    -- in this.
    extensions'fzf'
    -- This is needed to setup telescope-smart-history.
    extensions'smart_history'
    -- This is needed to setup projects.nvim
    extensions'projects'

    -- for telescope-frecency
    vim.api.nvim_exec([[
      hi link TelescopeBufferLoaded String
      hi link TelescopePathSeparator None
      hi link TelescopeFrecencyScores TelescopeResultsIdentifier
      hi link TelescopeQueryFilter Type
    ]], false)
  end,
}
