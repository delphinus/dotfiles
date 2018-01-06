if ! dein#is_sourced('vital.vim') | call dein#source('vital.vim') | endif

let s:V = vital#vital#new()
let s:FP = s:V.import('System.Filepath')

function! delphinus#tmux#tmux_filetype() abort
  if &filetype ==# 'tmux'
    return
  endif
  for ele in s:FP.split(expand('%'))
    if ele ==# '.tmux' || ele ==# 'tmux'
      set filetype=tmux
      return
    endif
  endfor
endfunction
