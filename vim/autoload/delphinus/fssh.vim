function! delphinus#fssh#fetch_env() abort
  let l:env_cmd = len($TMUX) ? 'tmux showenv' : 'env'
  let l:env = {}
  for l:line in systemlist(l:env_cmd . ' | grep LC_FSSH_')
    let [l:tmp, l:name, l:value] = matchlist(l:line, '^\([^=]\+\)=\(.*\)$')[:2]
    let l:env[l:name] = l:value
  endfor
  return l:env
endfunction

function! delphinus#fssh#is_enabled() abort
  let l:env = delphinus#fssh#fetch_env()
  return len(l:env['LC_FSSH_PORT'])
endfunction

function! delphinus#fssh#execute(command) abort
  let l:tmpfile = tempname()
  call writefile([a:command], l:tmpfile)
  let l:env = delphinus#fssh#fetch_env()
  let l:cmd = printf("ssh -p %d -l %s %s localhost PATH=%s 'bash -s' < %s",
        \ l:env['LC_FSSH_PORT'],
        \ l:env['LC_FSSH_USER'],
        \ l:env['LC_FSSH_COPY_ARGS'],
        \ l:env['LC_FSSH_PATH'],
        \ l:tmpfile,
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

  let l:error = systemlist('ui_copy', split(@", '\n'))
  if len(l:error)
    echoerr string(l:error)
  else
    echo 'copied from @" to system clipboard'
  endif
endfunction
