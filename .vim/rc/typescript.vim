let g:tsuquyomi_disable_default_mappings = 1
augroup TsuquyomiMappings
  autocmd!
  autocmd FileType typescript map <buffer> <C-]> <Plug>(TsuquyomiDefinition)
  autocmd FileType typescript map <buffer> <C-^> <Plug>(TsuquyomiReferences)
augroup END
