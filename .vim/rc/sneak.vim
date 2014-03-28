let g:sneak#streak = 1  " enable Streak-Mode
let g:sneak#f_reset = 1 " f mapping reset ; and .
let g:sneak#t_reset = 1 " t mapping reset ; and .
nmap s <Plug>SneakForward
nmap S <Plug>SneakBackward
nmap ; <Plug>SneakNext
nmap , <Plug>SneakPrevious
xmap s <Plug>VSneakForward
xmap S <Plug>VSneakBackward
xmap ; <Plug>VSneakNext
xmap , <Plug>VSneakPrevious
highlight SneakPluginTarget guifg=white guibg=magenta gui=bold ctermfg=15 ctermbg=46 cterm=bold
highlight SneakStreakTarget guibg=magenta guifg=white gui=bold ctermfg=46 ctermbg=15 cterm=bold
