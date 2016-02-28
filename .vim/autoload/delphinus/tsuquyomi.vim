let s:V = vital#of('vital')
let s:P = s:V.import('Prelude')

function! delphinus#tsuquyomi#detect_tsserver_path() abort
  let tsserver_path = s:P.path2project_directory(expand('%')) . '/node_modules/.bin/tsserver'
  if executable(tsserver_path)
    let g:tsuquyomi_tsserver_path = tsserver_path
  elseif exists('g:tsuquyomi_tsserver_path')
    unlet g:tsuquyomi_tsserver_path
  endif
endfunction
