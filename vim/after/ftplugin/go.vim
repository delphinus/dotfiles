set tabstop=4
set shiftwidth=4
set softtabstop=4
set foldmethod=syntax

augroup ExecDirenv
  autocmd!
  autocmd User RooterChDir call s:exec_direnv()
augroup END

function! s:exec_direnv() abort
  if !exists('b:gopath_set') && executable('direnv')
    execute system('direnv export vim 2>/dev/null')
    let b:gopath_set = 1
  endif
endfunction
