let s:V = vital#of('vital')
let s:P = s:V.import('Prelude')

function! airline#extensions#tabline#formatters#repo_directory#format(bufnr, buffers) abort
  let l:name = bufname(a:bufnr)
  let l:repo_directory = s:repo_directory(l:name)
  return airline#extensions#tabline#formatters#default#wrap_name(a:bufnr, l:repo_directory)
endfunction

function! s:repo_directory(name)
  if empty(a:name)
    return '[No Name]'
  endif

  let l:protocol = matchstr(a:name, '^[a-z][a-z0-9_]*\(:\)\@=')
  if l:protocol
    return l:protocol
  endif

  let l:repo_directory = s:P.path2project_directory(a:name)
  if len(l:repo_directory)
    let l:directory = fnamemodify(l:repo_directory, ':h:h') . '/'
  else
    let l:repo_directory = fnamemodify(a:name, ':h')
    let l:directory = fnamemodify(a:name, ':h:h')
    if l:directory !=# '/'
      let l:directory .= '/'
    endif
  endif

  return strpart(l:repo_directory, len(l:directory))
endfunction
