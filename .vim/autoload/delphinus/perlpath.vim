" This func refers to ftplugin/perl.vim in vim-perl
let g:my_perlpath = get(g:, 'my_perlpath', {})

function! delphinus#perlpath#set(perl_version) abort
  if has_key(g:my_perlpath, a:perl_version)
    call delphinus#perlpath#set_path(g:my_perlpath[a:perl_version])
  else
    call delphinus#perlpath#detect(a:perl_version)
  endif
endfunction

function! delphinus#perlpath#detect(perl_version) abort
  let s:stdout = ''
  let s:perl_version = a:perl_version
  let perl_exe = expand('~/.plenv/versions/' . a:perl_version . '/bin/perl')
  call jobstart([perl_exe, '-e', 'print join q/,/,@INC'], {
        \ 'on_stdout': 'delphinus#perlpath#on_event',
        \ 'on_exit': 'delphinus#perlpath#on_event',
        \ })
endfunction

function! delphinus#perlpath#on_event(job_id, data, event) abort
  if a:event ==# 'stdout'
    let s:stdout .= a:data[0]
  elseif a:event ==# 'exit'
    let g:my_perlpath[s:perl_version] = s:stdout
    call delphinus#perlpath#set_path(s:stdout)
  endif
endfunction

function! delphinus#perlpath#set_path(perlpath) abort
  if &g:path ==# ''
    let &l:path = a:perlpath
  else
    let &l:path = &g:path . ',' . a:perlpath
  endif
endfunction
