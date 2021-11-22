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
    m.nnoremap('<Leader>fb', function()
      local cwd = fn.expand'%:h'
      builtin'file_browser'{cwd = cwd == '' and nil or cwd}
    end)
    m.nnoremap('<Leader>ff', function()
      -- TODO: stopgap measure
      if loop.cwd() == loop.os_homedir() then
        api.echo({
          {
            'find_files on $HOME is danger. Launch file_browser instead.',
            'WarningMsg',
          },
        }, true, {})
        builtin'file_browser'{}
      -- TODO: use loop.fs_stat ?
      elseif fn.isdirectory(loop.cwd()..'/.git') == 1 then
        builtin'git_files'{}
      else
        builtin'find_files'{hidden = true}
      end
    end)
    m.nnoremap('<Leader>fg', function()
      builtin'grep_string'{
        only_sort_text = true,
        search = fn.input'Grep For ❯ ',
      }
    end)
    m.nnoremap('<Leader>f:', function() builtin'command_history'{} end)
    m.nnoremap('<Leader>fG', function() builtin'grep_string'{} end)
    m.nnoremap('<Leader>fH', function() builtin'help_tags'{lang = 'en'} end)
    m.nnoremap('<Leader>fP', function() extensions'packer'.plugins{} end)
    m.nnoremap('<Leader>fh', function() builtin'help_tags'{} end)
    m.nnoremap('<Leader>fm', function() builtin'man_pages'{sections = {'ALL'}} end)
    m.nnoremap('<Leader>fn', function() extensions'node_modules'.list{} end)
    m.nnoremap('<Leader>fo', function() builtin'oldfiles'{} end)
    m.nnoremap('<Leader>fp', function() extensions'projects'.projects{} end)
    m.nnoremap('<Leader>fq', function() extensions'ghq'.list{} end)
    m.nnoremap('<Leader>fr', function() builtin'resume'{} end)
    m.nnoremap('<Leader>fz', function() extensions'z'.list{} end)

    -- Memo
    m.nnoremap('<Leader>mm', function() extensions'memo'.list{} end)
    m.nnoremap('<Leader>mg', function()
      extensions'memo'.grep_string{
        only_sort_text = true,
        search = fn.input'Memo Grep For ❯ ',
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
    require'packer'.loader(
      'nvim-web-devicons popup.nvim sql.nvim '
      ..'telescope-fzf-native.nvim telescope-ghq.nvim telescope-github.nvim '
      ..'telescope-memo.nvim telescope-node-modules.nvim telescope-packer.nvim '
      ..'telescope-smart-history.nvim telescope-symbols.nvim telescope-z.nvim'
    )

    local actions = require'telescope.actions'
    local actions_state = require'telescope.actions.state'
    local telescope = require'telescope'
    local from_entry = require'telescope.from_entry'
    local builtin = function(name) return require'telescope.builtin'[name] end
    local extensions = function(name)
      return require'telescope'.load_extension(name)
    end
    local Path = require'plenary.path'

    local run_in_dir = function(prompt_bufnr, fn)
      local entry = actions_state.get_selected_entry()
      local dir = from_entry.path(entry)
      if fn.isdirectory(dir) then
        actions.close(prompt_bufnr)
        fn(dir)
      else
        api.echo(
          {{('This is not a directory: %s'):format(dir), 'WarningMsg'}}, true, {}
        )
      end
  end

    local run_find_files = function(prompt_bufnr)
      run_in_dir(prompt_bufnr, function(dir) builtin'find_files'{cwd = dir} end)
    end

    local run_live_grep = function(prompt_bufnr)
      run_in_dir(prompt_bufnr, function(dir) builtin'live_grep'{cwd = dir} end)
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
          path = Path:new(fn.stdpath'data', 'telescope_history.sqlite3').filename,
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
            vimrc = loop.os_homedir()..'/git/github.com/delphinus/dotfiles/.vim',
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
  end,
}
