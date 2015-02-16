if has('gui_macvim') && has('kaoriya')
  let execute_powerline = 'python'
elseif has('python')
  let execute_powerline = 'python'
else
  echoerr 'powerline needs if_python or if_python3 feature'
endif

let execute_powerline = execute_powerline . ' ' .
      \ 'from powerline.vim import setup as powerline_setup;' .
      \ 'powerline_setup();' .
      \ 'del powerline_setup'

execute execute_powerline
