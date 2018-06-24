if ! dein#is_sourced('vital.vim') | call dein#source('vital.vim') | endif

let s:V = vital#vital#new()
let s:FP = s:V.import('System.Filepath')
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

function! delphinus#ale#set_pylintrc() abort
  let buffer = bufnr('%')
  if get(b:, 'ale_python_pylint_options')
    return
  endif
  if ! get(b:, 'rcfile')
    let top_dir = s:P.path2project_directory(expand('%:p'))
    let b:rcfile = s:FP.join(top_dir, '.pylintrc')
  endif
  if ! filereadable(b:rcfile)
    return
  endif
  let b:ale_python_pylint_options = '--rcfile=' . shellescape(b:rcfile)
endfunction
