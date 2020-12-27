scriptencoding utf-8

let s:dein_dir = $HOME . '/.cache/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

let g:dein#install_progress_type = has('nvim') ? 'title' : 'tabline'
let g:dein#enable_notification = 1

if dein#load_state(s:dein_dir)
  let s:toml = [
        \ #{name: $HOME . '/.vim/rc/dein/default.toml',       lazy: 0},
        \ #{name: $HOME . '/.vim/rc/dein/lazy.toml',          lazy: 1},
        \ #{name: $HOME . '/.vim/rc/dein/denite_lazy.toml',   lazy: 1},
        "\ #{name: $HOME . '/.vim/rc/dein/defx_lazy.toml',     lazy: 1},
        "\ #{name: $HOME . '/.vim/rc/dein/deoplete_lazy.toml', lazy: 1},
        \ ]
  if has('nvim')
    call add(s:toml, #{name: $HOME . '/.vim/rc/dein/nvim-lua.toml', lazy: 0})
  endif
  " TODO: backup lightline settings
  " call add(s:toml, #{name: $HOME . '/.vim/rc/dein/lightline.toml', lazy: 0})

  call dein#begin(s:dein_dir, map(deepcopy(s:toml), {_, t -> t['name']}))
  call map(s:toml, {_, t -> dein#load_toml(t['name'], #{lazy: t['lazy']})})
  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

" TODO: hack for filetype
let g:did_load_filetypes = 1
filetype plugin indent on
