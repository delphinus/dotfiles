set tabstop=4
set shiftwidth=4
set softtabstop=4
set foldmethod=syntax

if !exists('b:gopath_set') && filereadable('.envrc') && executable('direnv')
  execute system('direnv export vim 2>/dev/null')
  let b:gopath_set = 1
endif
