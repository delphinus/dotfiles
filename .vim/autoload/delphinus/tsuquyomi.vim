let s:V = vital#of('vital')
let s:P = s:V.import('Prelude')

function! delphinus#tsuquyomi#init() abort
  let g:tsuquyomi_disable_default_mappings = 1
  let g:tsuquyomi_use_dev_node_module = 2
  let g:tsuquyomi_definition_split = 1
  let g:hoge_loaded=1
  call delphinus#tsuquyomi#detect_tsserver_path()

  augroup TsuquyomiMappings
    autocmd!
    autocmd FileType typescript map <buffer> <C-]> <Plug>(TsuquyomiDefinition)
    autocmd FileType typescript map <buffer> <C-^> <Plug>(TsuquyomiReferences)
  augroup END
endfunction

function! delphinus#tsuquyomi#detect_tsserver_path() abort
  let tsserver_path = s:P.path2project_directory(expand('%')) . '/node_modules/.bin/tsserver'
  if executable(tsserver_path)
    let g:tsuquyomi_tsserver_path = tsserver_path
  elseif exists('g:tsuquyomi_tsserver_path')
    unlet g:tsuquyomi_tsserver_path
  endif
endfunction
