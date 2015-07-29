let s:V = vital#of('vital')
let s:C = s:V.import('System.Cache.Memory')

function! delphinus#cache#singleton() abort
  if ! exists('g:delphinus#cache#instance')
    let g:delphinus#cache#instance = s:C.new()
  endif

  return g:delphinus#cache#instance
endfunction
