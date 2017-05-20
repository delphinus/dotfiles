function! delphinus#colorscheme#toggle() abort
  if &background ==# 'light'
    set background=dark
    colorscheme solarized8_dark
  else
    set background=light
    colorscheme solarized8_light
  endif
  let l:path = dein#get('lightline-delphinus').path
  execute 'source ' . l:path . '/autoload/lightline/colorscheme/solarized_improved.vim'
  call lightline#colorscheme()
endfunction
