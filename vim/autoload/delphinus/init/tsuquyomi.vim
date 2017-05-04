function! delphinus#init#tsuquyomi#hook_source() abort
  let g:tsuquyomi_disable_default_mappings = 1
  let g:tsuquyomi_use_dev_node_module = 1
  let g:tsuquyomi_definition_split = 1
  let g:tsuquyomi_completion_detail = 1

  augroup TsuquyomiMappings
    autocmd!
    autocmd FileType typescript map <buffer> <C-]> <Plug>(TsuquyomiDefinition)
    autocmd FileType typescript map <buffer> <C-@> <Plug>(TsuquyomiReferences)
  augroup END
endfunction
