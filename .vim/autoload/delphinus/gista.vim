if ! dein#is_sourced('vital.vim') | call dein#source('vital.vim') | endif

let s:V = vital#of('vital')
let s:F = s:V.import('System.Filepath')

function! delphinus#gista#yank_url_to_system_clipboard() abort
  let l:gista_action = {
        \ 'is_selectable': 0,
        \ 'description':   'yank a gist url to system clipboard',
        \ }

  if has('clipboard')
    let l:gista_action.func = function('delphinus#gista#star_register')
  else
    let l:gista_action.func = function('delphinus#gista#external')
  endif

  return l:gista_action
endfunction

function! delphinus#gista#star_register(candidate) abort
  let l:gist = gista#command#browse#call({'gist': a:candidate.source__entry})
  let @* = l:gist.url
endfunction

function! delphinus#gista#external(candidate) abort
  let l:gist = gista#command#browse#call({'gist': a:candidate.source__entry})
  if s:F.which('pbcopy') !=# ''
    call system(printf('echo "%s" | pbcopy', l:gist.url))
  elseif s:F.which('ui_copy') !=# ''
    call system(printf('echo "%s" | ui_copy', l:gist.url))
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
  let l:gista = gista#command#browse#call({'gist': a:candidate.source__entry})
  call openbrowser#open(l:gista.url)
endfunction
