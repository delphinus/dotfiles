if ! dein#is_sourced('vital.vim') | call dein#source('vital.vim') | endif

let s:cache_dir = expand('$HOME/.cache/vim')
let s:V = vital#vital#new()
let s:CM = s:V.import('System.Cache.Memory')
let s:CF = s:V.import('System.Cache.File')

function! delphinus#cache#memory() abort
  if ! exists('g:delphinus#cache#memory_instance')
    let g:delphinus#cache#memory_instance = s:CM.new()
  endif

  return g:delphinus#cache#memory_instance
endfunction

function! delphinus#cache#file() abort
  if ! exists('g:delphinus#cache#file_instance')
    let g:delphinus#cache#file_instance = s:CF.new({'cache_dir': s:cache_dir})
  endif

  return g:delphinus#cache#file_instance
endfunction
