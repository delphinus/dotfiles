require'augroups'.set{
  terminal_command = {
    {'TermOpen', 'term://*', function()
      vim.wo.scrolloff = 0
      vim.wo.number = false
      vim.wo.relativenumber = false
      vim.wo.cursorline = false
      vim.cmd[[startinsert]]
    end},
    {'WinEnter', 'term://*', 'startinsert'},
    {'WinEnter', 'term://*', 'doautocmd <nomodeline> FocusGained %'},
    {'WinLeave', 'term://*', 'doautocmd <nomodeline> FocusLost %'},
  },
}

for map, keys in pairs{
  ['<C-j>']  = {'<A-j>', '<A-∆>'},
  ['<C-k>']  = {'<A-k>', '<A-˚>'},
  ['<C-q>']  = {'<A-q>', '<A-œ>'},
  ['<C-s>']  = {'<A-s>', '<A-ß>'},
  [':']      = {'<A-;>', '<A-…>'},
  ['gt']     = {'<A-t>', '<A-†>'},
} do
  vimp.rbind('t', keys, [[<C-\><C-n>]]..map)
  vimp.rbind('n', keys, map)
end

vimp.rbind('t', {'<A-o>', '<A-ø>'}, [[<C-\><C-n><C-w>oi]])
vimp.rbind('n', {'<A-o>', '<A-ø>'}, [[<C-w>o]])
vimp.rbind('t', '<A-CR>', [[<C-\><C-n><A-CR>]])
vimp.bind('t', {'expr'}, {'<A-r>', '<A-®>'}, [['<C-\><C-n>"'.nr2char(getchar()).'pi']])
