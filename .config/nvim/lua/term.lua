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

local m = require'mappy'

for map, keys in pairs{
  ['<C-j>']  = {'<A-j>', '<A-∆>'},
  ['<C-k>']  = {'<A-k>', '<A-˚>'},
  ['<C-q>']  = {'<A-q>', '<A-œ>'},
  ['<C-s>']  = {'<A-s>', '<A-ß>'},
  [':']      = {'<A-;>', '<A-…>'},
  ['gt']     = {'<A-t>', '<A-†>'},
} do
  m.rbind('t', keys, [[<C-\><C-n>]]..map)
  m.rbind('n', keys, map)
end

m.rbind('t', {'<A-o>', '<A-ø>'}, [[<C-\><C-n><C-w>oi]])
m.rbind('n', {'<A-o>', '<A-ø>'}, [[<C-w>o]])
m.rbind('t', '<A-CR>', [[<C-\><C-n><A-CR>]])
m.bind('t', {'expr'}, {'<A-r>', '<A-®>'}, [['<C-\><C-n>"'.nr2char(getchar()).'pi']])
