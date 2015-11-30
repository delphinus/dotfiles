let g:tsuquyomi_disable_default_mappings = 1
let g:tsuquyomi_use_dev_node_module = 2
augroup TsuquyomiMappings
  autocmd!
  autocmd FileType typescript map <buffer> <C-]> <Plug>(TsuquyomiDefinition)
  autocmd FileType typescript map <buffer> <C-^> <Plug>(TsuquyomiReferences)
  autocmd FileType typescript execute 'let g:tsuquyomi_tsserver_path = "' . getcwd() . '/node_modules/.bin/tsserver"'
augroup END
