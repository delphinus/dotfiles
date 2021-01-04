return {
  'nvim-telescope/telescope.nvim',
  requires = {
    {'kyazdani42/nvim-web-devicons'},
    {'nvim-lua/popup.nvim'},
    {'nvim-telescope/telescope-packer.nvim'},
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
    local vimp = require'vimp'
    vimp.nnoremap('<Leader>ff', function() require'telescope.builtin'.git_files() end)
    vimp.nnoremap('<Leader>fg', function() require'telescope.builtin'.live_grep() end)
    vimp.nnoremap('<Leader>fb', function() require'telescope.builtin'.buffers() end)
    vimp.nnoremap('<Leader>fh', function() require'telescope.builtin'.help_tags() end)
    vimp.nnoremap('<Leader>fo', function() require'telescope.builtin'.oldfiles() end)

    local actions = require'telescope.actions'
    require'telescope'.setup{
      defaults = {
        mappings = {
          i = {
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-n>'] = actions.goto_file_selection_split,
          },
          n = {
            ['<C-c>'] = actions.close,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-n>'] = actions.goto_file_selection_split,
          },
        },
        winblend = 10,
      },
    }
  end,
}
