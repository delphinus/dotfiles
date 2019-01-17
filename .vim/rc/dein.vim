scriptencoding utf-8

let s:dein_dir = $HOME . '/.cache/dein'
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
  let s:toml = [
        \ {'name': 'default'},
        \ {'name': 'lazy',          'lazy': 1},
        \ {'name': 'defx_lazy',     'lazy': 1},
        \ {'name': 'denite_lazy',   'lazy': 1},
        \ {'name': 'deoplete_lazy', 'lazy': 1},
        \ ]
  let s:path = {name -> $HOME . '/.vim/rc/dein/' . name . '.toml'}
  let s:load_toml = {name, lazy -> dein#load_toml(s:path(name), {'lazy': lazy})}

  call dein#begin(s:dein_dir, map(deepcopy(s:toml), {_, t -> t['name']}))
  call map(s:toml, {_, t -> s:load_toml(t['name'], get(t, 'lazy', 0))})
  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

" TODO: hack for filetype
let g:did_load_filetypes = 1
filetype plugin indent on
