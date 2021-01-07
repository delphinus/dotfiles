return {
  'nvim-telescope/telescope.nvim',
  requires = {
    {'kyazdani42/nvim-web-devicons'},
    {'nvim-lua/popup.nvim'},
    {'nvim-telescope/telescope-ghq.nvim'},
    {'nvim-telescope/telescope-github.nvim'},
    {'nvim-telescope/telescope-packer.nvim'},
    {'nvim-telescope/telescope-symbols.nvim'},
    {'plenary.nvim'},
  },
  -- TODO: lazyloading
  --[[
  cmd = {'Telescope'},
  keys = {
    '<Leader>ff',
    '<Leader>fg',
    '<Leader>fb',
    '<Leader>fh',
  },
  ]]
  config = function()
    local actions = require'telescope.actions'
    local builtin = require'telescope.builtin'
    local telescope = require'telescope'
    local vimp = require'vimp'

    telescope.load_extension'ghcli'
    telescope.load_extension'ghq'

    vimp.nnoremap('<Leader>ff', builtin.git_files)
    vimp.nnoremap('<Leader>fg', builtin.live_grep)
    vimp.nnoremap('<Leader>fb', builtin.buffers)
    vimp.nnoremap('<Leader>fh', builtin.help_tags)
    vimp.nnoremap('<Leader>fo', builtin.oldfiles)
    vimp.nnoremap('<Leader>fq', builtin.ghq_list)
    vimp.nnoremap('<Leader>lr', builtin.lsp_references)
    vimp.nnoremap('<Leader>ld', builtin.lsp_document_symbols)
    vimp.nnoremap('<Leader>lw', builtin.lsp_workspace_symbols)
    vimp.nnoremap('<Leader>lc', builtin.lsp_code_actions)
    vimp.nnoremap('#', function() require'telescope.builtin'.current_buffer_fuzzy_find() end)

    local run_find_files = function(prompt_bufnr)
      local selection = actions.get_selected_entry()
      actions.close(prompt_bufnr)
      require'telescope.builtin'.find_files{cwd = selection.value}
    end

    telescope.setup{
      defaults = {
        mappings = {
          i = {
            ['<C-a>'] = run_find_files,
            ['<C-c>'] = actions.close,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-n>'] = actions.goto_file_selection_split,
          },
          n = {
            ['<C-a>'] = run_find_files,
            ['<C-c>'] = actions.close,
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
