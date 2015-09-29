let s:V = vital#of('vital')
let s:F = s:V.import('System.Filepath')

function! delphinus#gista#yank_url_to_system_clipboard() abort
  let gista_action = {
        \ 'is_selectable': 0,
        \ 'description': 'yank a gist url to system clipboard',
        \ }

  if has('clipboard')
    let gista_action.func = function('delphinus#gista#star_register')
  else
    let gista_action.func = function('delphinus#gista#external')
  endif

  return gista_action
endfunction

function! delphinus#gista#star_register(candidate) abort
  let gist = a:candidate.source__gist
  call gista#interface#yank_url_action(gist.id)
  let @* = @"
endfunction

function! delphinus#gista#external(candidate) abort
  let gist = a:candidate.source__gist
  call gista#interface#yank_url_action(gist.id)
  if s:F.which('pbcopy') !=# ''
    call system(printf('echo "%s" | pbcopy', @"))
  elseif s:F.which('ui_copy') !=# ''
    call system(printf('echo "%s" | ui_copy', @"))
  endif
endfunction

function! delphinus#gista#open_browser() abort
  let gista_action = {
        \ 'is_selectable': 0,
        \ 'description': 'open gist in browser',
        \ 'func': function('delphinus#gista#_open_browser'),
        \ }
  return gista_action
endfunction

function! delphinus#gista#_open_browser(candidate) abort
  let gist = a:candidate.source__gist
  call gista#interface#yank_url_action(gist.id)
  call openbrowser#open(@")
endfunction
