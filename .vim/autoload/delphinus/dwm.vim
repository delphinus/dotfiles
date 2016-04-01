function! delphinus#dwm#init() abort
  if ! exists('g:delphinus#dwm#min_master_pane_width')
    let g:delphinus#dwm#min_master_pane_width = 86
  endif

  let s:toggle_set_master_pane_width = 0

  nnoremap <C-J> <C-W>w
  nnoremap <C-K> <C-W>W
  nmap <C-T> <Plug>DWMRotateClockwise
  nmap <C-Q> <Plug>DWMRotateCounterclockwise
  nmap <C-N> <Plug>DWMNew
  nmap <C-C> <Plug>DWMClose
  nmap <C-@> <Plug>DWMFocus
  nmap <C-Space> <Plug>DWMFocus
  nmap <C-L> <Plug>DWMGrowMaster
  nmap <C-H> <Plug>DWMShrinkMaster
  nmap <BS>  <Plug>DWMShrinkMaster

  command! DWMSetMasterPaneWidth call delphinus#dwm#set_master_pane_width()
  command! DWMDisable call delphinus#dwm#disable()
  command! DWMEnable call delphinus#dwm#enable()
endfunction

function! delphinus#dwm#set_master_pane_width() abort
  if ! exists('*DWM_ResizeMasterPaneWidth')
    return
  endif
  if s:toggle_set_master_pane_width
    let s:toggle_set_master_pane_width = 0
    if exists('g:dwm_master_pane_width') && g:dwm_master_pane_width !=# &columns / 2
      let g:dwm_master_pane_width = &columns / 2
      call DWM_ResizeMasterPaneWidth()
    endif
  else
    let s:toggle_set_master_pane_width = 1
    if g:delphinus#dwm#min_master_pane_width > &columns / 2
      let g:dwm_master_pane_width = g:delphinus#dwm#min_master_pane_width
      call DWM_ResizeMasterPaneWidth()
    endif
  endif
endfunction

function! delphinus#dwm#disable() abort
  autocmd! dwm BufWinEnter
  augroup! dwm
endfunction

function! delphinus#dwm#enable() abort
  augroup dwm
    autocmd!
    autocmd BufWinEnter * if &l:buflisted || &l:filetype == 'help' | call DWM_AutoEnter() | endif
  augroup END
endfunction
