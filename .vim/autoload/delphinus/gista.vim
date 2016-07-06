if ! dein#is_sourced('vital.vim') | call dein#source('vital.vim') | endif

let s:V = vital#of('vital')
let s:F = s:V.import('System.Filepath')

function! delphinus#gista#yank_url_to_system_clipboard() abort
  let l:gista_action = {
        \ 'is_selectable': 0,
        \ 'description':   'yank a gist url to system clipboard',
        \ }

  if has('clipboard') && has('macunix')
    let l:gista_action.func = function('delphinus#gista#star_register')
  else
    let l:gista_action.func = function('delphinus#gista#external')
  endif

  return l:gista_action
endfunction

function! delphinus#gista#star_register(candidate) abort
  let @* = a:candidate.action__uri
endfunction

function! delphinus#gista#external(candidate) abort
  let l:uri = a:candidate.action__uri
  if s:F.which('pbcopy') !=# ''
    call system(printf('echo -n "%s" | pbcopy', l:uri))
    echo printf('copy to system clipboard with pbcopy: %s', l:uri)
  elseif s:F.which('ui_copy') !=# ''
    call system(printf('echo "%s" | ui_copy', l:uri))
    echo printf('copy to system clipboard with fssh: %s', l:uri)
  endif
endfunction

function! delphinus#gista#open_browser() abort
  return {
        \ 'is_selectable': 0,
        \ 'description':   'open gist in browser',
        \ 'func':          function('delphinus#gista#_open_browser'),
        \ }
endfunction

function! delphinus#gista#_open_browser(candidate) abort
  call openbrowser#open(a:candidate.action__uri)
endfunction
