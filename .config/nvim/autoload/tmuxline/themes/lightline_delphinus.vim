function! tmuxline#themes#lightline_delphinus#get() abort
  if !exists('*lightline#palette')
    throw "tmuxline: Can't load theme from lightline, function lightline#palette() doesn't exist. Is latest lightline loaded?"
  endif

  let palette = lightline#palette()
  let mode = 'normal'
  let mode_palette = palette[mode]
  let theme = {
        \ 'a' : mode_palette.left[0][0:1],
        \ 'b' : mode_palette.left[1][0:1],
        \ 'c' : mode_palette.left[2][0:1],
        \ 'x' : mode_palette.middle[0][0:1],
        \ 'y' : mode_palette.right[1][0:1],
        \ 'z' : mode_palette.right[0][0:1],
        \ 'bg' : mode_palette.middle[0][0:1],
        \ 'cwin' : mode_palette.left[1][0:1],
        \ 'win' : mode_palette.middle[0][0:1]}
  call tmuxline#util#try_guess_activity_color(theme)
  return theme
endfunc
