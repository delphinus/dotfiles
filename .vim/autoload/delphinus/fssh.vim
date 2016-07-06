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
