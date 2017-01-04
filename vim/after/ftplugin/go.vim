set tabstop=4
set shiftwidth=4
set softtabstop=4
set foldmethod=marker

if ! exists('b:goroot_setting')
  if ! exists('g:goroot')
    let g:goroot = substitute(system('go env GOROOT'), '\n', '', 'g')
  endif
  if ! exists('g:gopath')
    let g:gopath = split(systemlist('go env GOPATH')[0], ':')
  endif
  let s:gopath_joined = join(map(g:gopath, { i, x -> x . '/src' }), ',')
  execute 'setlocal path=' . join(['.', 'vendor', g:goroot . '/src', s:gopath_joined], ',')
  let b:goroot_setting = 1
endif
