return {
  'nvim-telescope/telescope.nvim',
  requires = {
    {'delphinus/telescope-memo.nvim', opt = true},
    {'delphinus/telescope-node-modules.nvim', opt = true},
    {'delphinus/telescope-z.nvim', opt = true},
    {'kyazdani42/nvim-web-devicons', opt = true},
    {'nvim-lua/popup.nvim', opt = true},
    {'nvim-telescope/telescope-ghq.nvim', opt = true},
    {'nvim-telescope/telescope-github.nvim', opt = true},
    {'nvim-telescope/telescope-packer.nvim', opt = true},
    {'nvim-telescope/telescope-symbols.nvim', opt = true},
    {'plenary.nvim'},

    {
      -- 'nvim-telescope/telescope-frecency.nvim',
      'delphinus/telescope-frecency.nvim',
      requires = {'tami5/sql.nvim'},
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
    local vimp = require'vimp'

    local run_find_files = function(prompt_bufnr)
      local selection = actions.get_selected_entry()
      actions.close(prompt_bufnr)
      require'telescope.builtin'.find_files{cwd = selection.value}
    end

    local run_live_grep = function(prompt_bufnr)
      local selection = actions.get_selected_entry()
      if vim.fn.isdirectory(selection.value) == 1 then
        actions.close(prompt_bufnr)
        require'telescope.builtin'.live_grep{cwd = selection.value}
      else
        vim.api.nvim_echo({{'This is not a directory.', 'WarningMsg'}}, true, {})
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
            ['<C-n>'] = actions.goto_file_selection_split,
          },
          n = {
            ['<C-a>'] = run_find_files,
            ['<C-c>'] = actions.close,
            ['<C-g>'] = run_live_grep,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-n>'] = actions.goto_file_selection_split,
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
          ignore_patterns = {'/.git/'},
        },
      },
    }
    -- TODO: how to use this?
    -- telescope.load_extension'packer'

    telescope.load_extension'frecency'
    telescope.load_extension'gh'
    telescope.load_extension'ghq'
    telescope.load_extension'memo'
    telescope.load_extension'z'
    telescope.load_extension'node_modules'
    local extensions = telescope.extensions

    -- file finders
    vimp.nnoremap('<Leader>ff', builtin.git_files)
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
