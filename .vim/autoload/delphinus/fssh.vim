function! delphinus#fssh#is_enabled() abort
  return exists('$LC_FSSH_PORT')
endfunction

function! delphinus#fssh#execute(command) abort
  let l:cmd = printf('ssh -p %d -l %s %s localhost PATH=%s %s',
        \ $LC_FSSH_PORT,
        \ $LC_FSSH_USER,
        \ $LC_FSSH_COPY_ARGS,
        \ $LC_FSSH_PATH,
        \ a:command,
        \ )
  echo 'fssh execute: ' . a:command
  call system(l:cmd)
endfunction

function! delphinus#fssh#open(url) abort
  call delphinus#fssh#execute('open ' . a:url)
endfunction

function! delphinus#fssh#copy() abort
  if ! delphinus#fssh#is_enabled()
    echoerr 'fssh is not enabled!'
    return
  endif

  let l:error = systemlist('ui_copy 2>&1', split(@", '\n'))
  if len(l:error)
    echoerr string(l:error)
  else
    echo 'copied from @" to system clipboard'
  endif
endfunction
