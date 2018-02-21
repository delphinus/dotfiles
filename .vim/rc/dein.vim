scriptencoding utf-8

let s:dein_dir = expand(g:home . '/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

let g:dein#install_progress_type = 'title'
let g:dein#enable_notification = 1

if dein#load_state(s:dein_dir)
  function! s:toml_path(name) abort
    return printf('%s/dein/%s.toml', g:rc_dir, a:name)
  endfunction
  let s:toml = [
        \ {'name': 'default', 'non_lazy': 1},
        \ {'name': 'deoplete', 'non_lazy': 1},
        \ {'name': 'denite', 'non_lazy': 1},
        \ {'name': 'lazy'},
        \ {'name': 'denite_lazy'},
        \ {'name': 'deoplete_lazy'},
        \ {'name': 'map'},
        \ {'name': 'cmd'},
        \ {'name': 'ft'},
        \ {'name': 'event'},
        \ ]
  let s:names = []
  for s:t in s:toml
    call add(s:names, s:toml_path(s:t['name']))
  endfor

  call dein#begin(s:dein_dir, s:names)
  for s:t in s:toml
    let s:is_lazy = !get(s:t, 'non_lazy', 0)
    call dein#load_toml(s:toml_path(s:t['name']), {'lazy': s:is_lazy})
  endfor
  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

" TODO: hack for filetype
let g:did_load_filetypes = 1
filetype plugin indent on
