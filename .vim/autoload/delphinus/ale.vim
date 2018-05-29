if ! dein#is_sourced('vital.vim') | call dein#source('vital.vim') | endif

let s:V = vital#vital#new()
let s:P = s:V.import('Prelude')

function! delphinus#ale#pylint() abort
  if dein#tap('denite.nvim')
    let top_dir = s:P.path2project_directory(expand('%:p'))
    let hook = 'import sys;'
    let hook .= 'sys.path.append("' . g:dein#plugin.rtp . '/rplugin/python3");'
    let hook .= 'sys.path.append("' . g:home . '/.vim/rplugin/python3");'
    let hook .= 'sys.path.append("' . top_dir . '/rplugin/python3");'
    let b:ale_python_pylint_options = '--init-hook=''' . hook . ''''
  endif
endfunction
