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

local vimp = require'vimp'
vimp.tmap('<A-j>', [[<C-\><C-n><C-j>]])
vimp.tmap('<A-k>', [[<C-\><C-n><C-k>]])
vimp.tmap('<A-o>', [[<C-\><C-n><C-w>oi]])
vimp.tmap('<A-q>', [[<C-\><C-n><C-q>]])
vimp.tmap('<A-s>', [[<C-\><C-n><C-s>]])
vimp.tmap('<A-;>', [[<C-\><C-n>:]])
vimp.tmap('<A-t>', [[<C-\><C-n>gt]])
vimp.nmap('<A-j>', [[<C-j>]])
vimp.nmap('<A-k>', [[<C-k>]])
vimp.nmap('<A-o>', [[<C-w>o]])
vimp.nmap('<A-q>', [[<C-q>]])
vimp.nmap('<A-s>', [[<C-s>]])
vimp.nmap('<A-;>', [[:]])
vimp.nmap('<A-t>', [[gt]])
vimp.tmap('<A-CR>', [[<C-\><C-n><A-CR>]])
vimp.tnoremap({'expr'}, '<A-r>', [['<C-\><C-n>"'.nr2char(getchar()).'pi']])
