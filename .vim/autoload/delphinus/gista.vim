if ! dein#is_sourced('vital.vim') | call dein#source('vital.vim') | endif

let s:V = vital#of('vital')
let s:F = s:V.import('System.Filepath')

function! delphinus#gista#yank_url_to_system_clipboard() abort
  let gista_action = {
        \ 'is_selectable': 0,
        \ 'description':   'yank a gist url to system clipboard',
        \ }

  if has('clipboard') && has('macunix')
    let gista_action.func = function('delphinus#gista#star_register')
  else
    let gista_action.func = function('delphinus#gista#external')
  endif

  return gista_action
endfunction

function! delphinus#gista#star_register(candidate) abort
  let @* = a:candidate.action__uri
endfunction

function! delphinus#gista#external(candidate) abort
  let uri = a:candidate.action__uri
  if s:F.which('pbcopy') !=# ''
    call system(printf('echo -n "%s" | pbcopy', uri))
    echo printf('copy to system clipboard with pbcopy: %s', uri)
  elseif s:F.which('ui_copy') !=# ''
    call system(printf('echo -n "%s" | ui_copy', uri))
    echo printf('copy to system clipboard with fssh: %s', uri)
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
  if delphinus#fssh#is_enabled()
    call delphinus#fssh#open(a:candidate.action__uri)
  else
    call openbrowser#open(a:candidate.action__uri)
  endif
endfunction
