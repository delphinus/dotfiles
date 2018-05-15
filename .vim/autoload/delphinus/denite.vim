function! delphinus#denite#with_pwd(action) abort
  let pwd = get(b:, '__pwd__', '')
  if a:action ==# 'grep'
    call denite#start([{'name': 'grep', 'args': [pwd, '', '!']}])
  else
    call denite#start([{'name': a:action, 'args': ['', pwd]}])
  endif
endfunction

function! delphinus#denite#file_rec_goroot() abort
  if !executable('go')
    echoerr '`go` executable not found'
    return
  endif
  let out = system('go env | grep ''^GOROOT='' | cut -d\" -f2')
  let goroot = substitute(out, '\n', '', '')
  call denite#start(
        \ [{'name': 'file_rec', 'args': [goroot]}],
        \ {'input': '.go '})
endfunction

function! delphinus#denite#outline() abort
  execute 'Denite' &filetype ==# 'go' ? 'decls:''%:p''' : 'outline'
endfunction

function! delphinus#denite#decls() abort
  if &filetype ==# 'go'
    Denite decls
  else
    call denite#util#print_error('decls does not support filetypes except go')
  endif
endfunction
