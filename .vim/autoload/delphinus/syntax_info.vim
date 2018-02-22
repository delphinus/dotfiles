scriptencoding utf-8

" カーソル下のシンタックスハイライト情報を得る
" http://cohama.hateblo.jp/entry/2013/08/11/020849
function! delphinus#syntax_info#get_syn(transparent) abort
  let l:synid = synID(line('.'), col('.'), 1)
  if a:transparent
    let l:synid = synIDtrans(l:synid)
  endif
  return {
        \ 'name':    synIDattr(l:synid, 'name'),
        \ 'ctermfg': synIDattr(l:synid, 'fg', 'cterm'),
        \ 'ctermbg': synIDattr(l:synid, 'bg', 'cterm'),
        \ 'guifg':   synIDattr(l:synid, 'fg', 'gui'),
        \ 'guibg':   synIDattr(l:synid, 'bg', 'gui'),
        \ }
endfunction

function! delphinus#syntax_info#string(syn) abort
  return join(
        \ map(['name', 'ctermfg', 'ctermbg', 'guifg', 'guibg'],
        \   {_, key -> key . ': ' . a:syn[key]}),
        \ ' ')
endfunction

function! delphinus#syntax_info#get_info() abort
  let l:base_syn = delphinus#syntax_info#get_syn(0)
  echo delphinus#syntax_info#string(l:base_syn)
  let l:linked_syn = delphinus#syntax_info#get_syn(1)
  echo 'linked to'
  echo delphinus#syntax_info#string(l:linked_syn)
endfunction
