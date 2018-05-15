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
    autocmd BufWinEnter * if &buflisted || &filetype == 'help' | call DWM_AutoEnter() | endif
  augroup END
endfunction
