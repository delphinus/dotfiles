return {
  'nvim-telescope/telescope.nvim',
  requires = {
    {'nvim-lua/plenary.nvim'},
    {'nvim-lua/popup.nvim'},
    {'kyazdani42/nvim-web-devicons'},
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

    require'telescope'.setup{
      defaults = {
        winblend = 10,
      },
    }
  end,
}
