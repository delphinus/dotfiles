scriptencoding utf-8

let s:spc = g:airline_symbols.space

function! airline#extensions#watchdogs#get_warnings() abort
  let b:bufnr = get(b:, 'bufnr', bufnr(''))
  let l:errors = filter(getqflist(), 'v:val.bufnr == b:bufnr')
  if len(l:errors)
    return printf('%sERR:  %d (%d)', s:spc, l:errors[0].lnum, len(l:errors))
  else
    return ''
  endif
endfunction

function! airline#extensions#watchdogs#init(ext) abort
  call airline#parts#define_function('watchdogs', 'airline#extensions#watchdogs#get_warnings')
endfunction
