if has('python')
  execute 'python ' .
        \ 'from powerline.vim import setup as powerline_setup;' .
        \ 'powerline_setup();' .
        \ 'del powerline_setup'
endif
