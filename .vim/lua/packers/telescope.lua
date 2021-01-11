return {
  'nvim-telescope/telescope.nvim',
  requires = {
    {'delphinus/telescope-z.nvim', opt = true},
    {'kyazdani42/nvim-web-devicons', opt = true},
    {'nvim-lua/popup.nvim', opt = true},
    {'nvim-telescope/telescope-ghq.nvim', opt = true},
    {'nvim-telescope/telescope-github.nvim', opt = true},
    {'nvim-telescope/telescope-packer.nvim', opt = true},
    {'nvim-telescope/telescope-symbols.nvim', opt = true},
    {'plenary.nvim'},
  },
  cmd = {'Telescope'},
  keys = {
    '<Leader>ff',
    '<Leader>fg',
    '<Leader>fb',
    '<Leader>fh',
    '<Leader>fo',
    '<Leader>fq',
    '<Leader>fz',
    '<Leader>sr',
    '<Leader>sd',
    '<Leader>sw',
    '<Leader>sc',
    '#',
  },
  config = function()
    for _, name in pairs{
      'nvim-web-devicons',
      'popup.nvim',
      'telescope-ghq.nvim',
      'telescope-github.nvim',
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

    telescope.load_extension'gh'
    telescope.load_extension'ghq'
    telescope.load_extension'z'

    vimp.nnoremap('<Leader>ff', builtin.git_files)
    vimp.nnoremap('<Leader>fg', builtin.live_grep)
    vimp.nnoremap('<Leader>fb', builtin.buffers)
    vimp.nnoremap('<Leader>fh', builtin.help_tags)
    vimp.nnoremap('<Leader>fo', builtin.oldfiles)
    vimp.nnoremap('<Leader>fq', telescope.extensions.ghq.list)
    vimp.nnoremap('<Leader>fz', telescope.extensions.z.list)
    vimp.nnoremap('<Leader>sr', builtin.lsp_references)
    vimp.nnoremap('<Leader>sd', builtin.lsp_document_symbols)
    vimp.nnoremap('<Leader>sw', builtin.lsp_workspace_symbols)
    vimp.nnoremap('<Leader>sc', builtin.lsp_code_actions)
    vimp.nnoremap('#', builtin.current_buffer_fuzzy_find)

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
        vim.cmd[[echohl WarningMsg]]
        vim.cmd[[echomsg 'This is not a directory.']]
        vim.cmd[[echohl None]]
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
      },
    }
    -- TODO: how to use this?
    -- telescope.load_extension'packer'
  end,
}
