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
