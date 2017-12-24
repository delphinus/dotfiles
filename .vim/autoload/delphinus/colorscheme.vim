function! delphinus#colorscheme#toggle() abort
  if &background ==# 'light'
    set background=dark
    colorscheme solarized8_dark
  else
    set background=light
    colorscheme solarized8_light
  endif
  call delphinus#colorscheme#setGoSameId()
  let l:path = dein#get('lightline-delphinus').path
  let l:color = g:colors_name ==# 'nord' ? 'nord_improved' : 'solarized_improved'
  let g:lightline_delphinus_colorscheme = l:color
  execute 'source' l:path . '/autoload/lightline/colorscheme/' . l:color . '.vim'
  unlet g:loaded_lightline_delphinus
  execute 'source' l:path . '/plugin/lightline_delphinus.vim'

  " https://github.com/itchyny/lightline.vim/issues/241#issuecomment-322033789
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction

function! delphinus#colorscheme#setGoSameId() abort
  if !dein#is_sourced('vim-go')
    return
  endif

  if &background ==# 'light'
    hi! goSameId term=bold cterm=bold ctermbg=225 guibg=#eeeaec
  else
    hi! goSameId term=bold ctermbg=23 ctermfg=7 guifg=#eee8d5 guibg=#00533f
  endif
endfunction
