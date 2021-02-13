scriptencoding utf-8

" カーソル下のシンタックスハイライト情報を得る
" http://cohama.hateblo.jp/entry/2013/08/11/020849
function! delphinus#syntax_info#get_syn(transparent) abort
  let synid = synID(line('.'), col('.'), 1)
  if a:transparent
    let synid = synIDtrans(synid)
  endif
  return {
        \ 'name':    synIDattr(synid, 'name'),
        \ 'ctermfg': synIDattr(synid, 'fg', 'cterm'),
        \ 'ctermbg': synIDattr(synid, 'bg', 'cterm'),
        \ 'guifg':   synIDattr(synid, 'fg', 'gui'),
        \ 'guibg':   synIDattr(synid, 'bg', 'gui'),
        \ }
endfunction

function! delphinus#syntax_info#string(syn) abort
  return join(
        \ map(['name', 'ctermfg', 'ctermbg', 'guifg', 'guibg'],
        \   {_, key -> key . ': ' . a:syn[key]}),
        \ ' ')
endfunction

function! delphinus#syntax_info#get_info() abort
  let base_syn = delphinus#syntax_info#get_syn(0)
  echo delphinus#syntax_info#string(base_syn)
  let linked_syn = delphinus#syntax_info#get_syn(1)
  echo 'linked to'
  echo delphinus#syntax_info#string(linked_syn)
endfunction
