scriptencoding 'utf-8'

let g:is_remora_cx = hostname() == 'remora'
let g:is_remora = hostname() =~ '^remora'
let g:is_remora_air2 = hostname() =~ '^remora-air2'
let g:is_backup = hostname() =~ 'backup\d\?.remora.cx'
let g:is_office = hostname() !~ 'remora' && len($H) > 0 && has('unix')
let g:is_office_win = len($USERDOMAIN) && has('win32')
let g:is_office_cygwin = len($USERDOMAIN) && has('win32unix')
let g:is_office_alt = is_office && $VIM_ENV_ALT
let g:is_xerxes = hostname() == 'xerxes'
let g:is_remora_air2_win = hostname() == 'remora-air2-win'
let g:is_unix = is_remora || is_backup || is_office || is_office_cygwin
let g:is_win = is_office_win || is_xerxes || is_remora_air2_win

if is_remora || is_office_cygwin || is_backup
    let g:home = expand('~')
elseif is_office
    let g:home = expand('$H')
elseif is_win
    let g:home = expand('$HOME')
else
    finish
endif

let g:vim_home = g:home . '/.vim'
let g:source_dir = g:vim_home . '/rc'

function s:loadrc(file)
	execute 'source ' . g:source_dir . '/' . a:file . '.vim'
endfunction

" プラグインの読み込み
call s:loadrc('neobundle')
" マッピング
call s:loadrc('map')
" オプション設定
call s:loadrc('set')
" ターミナル固有の設定
call s:loadrc('term')
" ユーティリティ関数
call s:loadrc('functions')

" QFixMemo 設定
call s:loadrc('qfixmemo')
" QuickRun 設定
call s:loadrc('quickrun')
" Perl 設定
call s:loadrc('perl')
" Ref 設定
call s:loadrc('ref')
" Netrw 設定
call s:loadrc('netrw')
" Unite 設定
call s:loadrc('unite')
" VimFiler 設定
call s:loadrc('vimfiler')
" neocomplcache 設定
call s:loadrc('neocomplcache')
" VimShell 設定
call s:loadrc('vimshell')
" Powerline 設定
call s:loadrc('powerline')
" JpFormat 設定
call s:loadrc('jpformat')
" TweetVim 設定
call s:loadrc('tweetvim')
" Gist 設定
call s:loadrc('gist')
" jsl 設定
call s:loadrc('jsl')
" DrawIt 設定
call s:loadrc('drawit')
" Chalice 設定
call s:loadrc('chalice')
" vim-funlib 設定
call s:loadrc('funlib')
" errormarker 設定
call s:loadrc('errormarker')
" EasyMotion 設定
call s:loadrc('easymotion')
" YankRing 設定
call s:loadrc('yankring')
" cmdline-completion 設定
call s:loadrc('cmdline-completion')
" シンタックスチェック
"call s:loadrc('syntastic')
" http://d.hatena.ne.jp/osyo-manga/20110921/1316605254
"call s:loadrc('syntaxcheck')
" CSV 設定
call s:loadrc('csv')
" markdown 設定
call s:loadrc('markdown')
" Clam 設定
call s:loadrc('clam')
" TimeTap 設定
call s:loadrc('timetap')
" Tagbar 設定
call s:loadrc('tagbar')
" pb.vim 設定
call s:loadrc('pb')
" vim-rooter 設定
call s:loadrc('rooter')
" tabrecent 設定
call s:loadrc('tabrecent')
" screen title 設定
call s:loadrc('title')
" activefix 設定
"call s:loadrc('activefix')
" sunset 設定
"call s:loadrc('sunset')
" Pastefire 設定
call s:loadrc('pastefire')
" Auto Pairs 設定
"call s:loadrc('autopairs')
" fugitive 設定
call s:loadrc('fugitive')
" Extradite 設定
call s:loadrc('extradite')
" golden-ratio 設定
call s:loadrc('goldenratio')
" Colorizer 設定
call s:loadrc('colorizer')
" trans.vim 設定
call s:loadrc('trans')
" Indent Guides 設定
call s:loadrc('indent-guides')
" easybuffer 設定
call s:loadrc('easybuffer')
" PSearch 設定
call s:loadrc('psearch')
" watchdogs 設定
call s:loadrc('watchdogs')
" vim-seek 設定
call s:loadrc('seek')
" dwm.vim 設定
call s:loadrc('dwm')
" vim-multiple-cursors 設定
call s:loadrc('multiple-cursors')
" breeze.vim 設定
"call s:loadrc('breeze')
" javascript 設定
call s:loadrc('javascript')

" オフィス専用設定
let g:office_vimrc = g:home . '/git/dotfiles-office/.vimrc'
if is_office && filereadable(g:office_vimrc)
	execute 'source ' . g:office_vimrc
endif

" 無効化したもの
"call s:loadrc('disabled')
" ステータスバー設定
"call s:loadrc('statusbar')
" タブ設定
call s:loadrc('tab')
" gmail.vim 設定
call s:loadrc('gmail')
