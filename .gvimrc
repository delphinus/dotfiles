if is_win
	set guifont=Envy_Code_R_for_Powerline:h10
	set guifontwide=Ricty:h10
	set dir=C:\cygwin\tmp
	set backupdir=C:\cygwin\tmp
	set undodir=C:\cygwin\tmp
    "set listchars=tab:»\ ,trail:‗,eol:↲,extends:»,precedes:«,nbsp:¯

elseif is_remora_cx
	set guifont=Envy_Code_R_for_Powerline:h16
	set guifontwide=Ricty_Envy:h16
else
	set guifont=Envy_Code_R_for_Powerline:h13
	set guifontwide=Ricty:h13
endif
if is_remora
	set antialias
	set fuoptions=maxvert,maxhorz
	au GUIEnter * set fullscreen
endif
set showtabline=2
set printfont=Consolas:h9
set printoptions=number:y
set visualbell
set iminsert=0
set imsearch=-1
set mouse=a
set clipboard=
set guioptions=A
set linespace=0
set ambiwidth=single
"colo desert-warm-256
"colo bubblegum
"colo neon-PK
"colo zenburn
"colo papayawhip
"colo gummybears
colo void
