return {
  --'nvim-telescope/telescope.nvim',
  --'Conni2461/telescope.nvim',
  'delphinus/telescope.nvim',
  branch = 'file_browser',
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
      --'nvim-telescope/telescope-frecency.nvim',
      'delphinus/telescope-frecency.nvim',
      branch = 'hotfix/disable-mappings-override',
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
  keys = {
    '<Leader>ff',
    '<Leader>fg',
    '<Leader>fb',
    '<Leader>fh',
    '<Leader>fm',
    '<Leader>fo',
    '<Leader>fp',
    '<Leader>fq',
    '<Leader>fz',
    '<Leader>mm',
    '<Leader>mg',
    '<Leader>sr',
    '<Leader>sd',
    '<Leader>sw',
    '<Leader>sc',
    '<Leader>gc',
    '<Leader>gb',
    '<Leader>gr',
    '<Leader>gs',
    '#',
  },
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
    local builtin = require'telescope.builtin'
    local telescope = require'telescope'
    local extensions = telescope.extensions
    local vimp = require'vimp'

    local run_find_files = function(prompt_bufnr)
      local selection = actions.get_selected_entry()
      actions.close(prompt_bufnr)
      builtin.find_files{cwd = selection.value}
    end

    local run_live_grep = function(prompt_bufnr)
      local selection = actions.get_selected_entry()
      if vim.fn.isdirectory(selection.value) == 1 then
        actions.close(prompt_bufnr)
        extensions.fzf_writer.staged_grep{cwd = selection.value}
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
            ['<C-s>'] = actions.goto_file_selection_split,
            ['<C-n>'] = actions.goto_file_selection_split,
            ['<C-d>'] = preview_scroll(3),
            ['<C-u>'] = preview_scroll(-3),
          },
          n = {
            ['<C-a>'] = run_find_files,
            ['<C-c>'] = actions.close,
            ['<C-g>'] = run_live_grep,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-s>'] = actions.goto_file_selection_split,
            ['<C-n>'] = actions.goto_file_selection_split,
            ['<C-d>'] = preview_scroll(3),
            ['<C-u>'] = preview_scroll(-3),
          },
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
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
            vimrc = vim.env.HOME..'/git/github.com/delphinus/dotfiles/.vim',
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

    telescope.load_extension'frecency'
    telescope.load_extension'fzf_writer'
    telescope.load_extension'gh'
    telescope.load_extension'ghq'
    telescope.load_extension'memo'
    telescope.load_extension'node_modules'
    telescope.load_extension'z'

    -- file finders
    vimp.nnoremap('<Leader>ff', function()
      -- TODO: stopgap measure
      local cwd = vim.fn.getcwd()
      if cwd == vim.loop.os_homedir() then
        vim.api.nvim_echo({
          {'find_files on $HOME is danger. Launch ghq instead.', 'WarningMsg'},
        }, true, {})
        extensions.ghq.list{}
      elseif vim.fn.isdirectory(cwd..'/.git') then
        builtin.git_files{}
      else
        builtin.find_files{}
      end
    end)

    vimp.nnoremap('<Leader>fa', function()
      builtin.find_files{hidden = true}
    end)
    vimp.nnoremap('<Leader>fb', function()
      local ok, _ = pcall(builtin.file_browser, {})
      if not ok then
        vim.api.nvim_echo({
          {'This revision does not have :Telescope file_browser', 'WarningMsg'},
        }, true, {})
      end
    end)

    vimp.nnoremap('<Leader>fg', builtin.live_grep)
    vimp.nnoremap('<Leader>fb', builtin.buffers)
    vimp.nnoremap('<Leader>fh', builtin.help_tags)
    vimp.nnoremap('<Leader>fm', builtin.man_pages)
    vimp.nnoremap('<Leader>fo', extensions.frecency.frecency)
    vimp.nnoremap('<Leader>fp', extensions.node_modules.list)
    vimp.nnoremap('<Leader>fq', extensions.ghq.list)
    vimp.nnoremap('<Leader>fz', extensions.z.list)

    -- for Memo
    vimp.nnoremap('<Leader>mm', extensions.memo.list)
    vimp.nnoremap('<Leader>mg', extensions.memo.grep)

    -- for LSP
    vimp.nnoremap('<Leader>sr', builtin.lsp_references)
    vimp.nnoremap('<Leader>sd', builtin.lsp_document_symbols)
    vimp.nnoremap('<Leader>sw', builtin.lsp_workspace_symbols)
    vimp.nnoremap('<Leader>sc', builtin.lsp_code_actions)

    -- for Git
    vimp.nnoremap('<Leader>gc', builtin.git_commits)
    vimp.nnoremap('<Leader>gb', builtin.git_bcommits)
    vimp.nnoremap('<Leader>gr', builtin.git_branches)
    vimp.nnoremap('<Leader>gs', builtin.git_status)

    -- for buffer
    vimp.nnoremap('#', builtin.current_buffer_fuzzy_find)
  end,
}
