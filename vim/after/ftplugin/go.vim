set tabstop=4
set shiftwidth=4
set softtabstop=4
set includeexpr=substitute(v:fname,'\\.','/','g')

if ! exists('b:goroot_setting')
  if ! exists('g:goroot')
    let g:goroot = substitute(system('go env GOROOT'), '\n', '', 'g')
  endif
  execute 'setlocal path+=' . g:goroot . '/src'
  let b:goroot_setting = 1
endif
