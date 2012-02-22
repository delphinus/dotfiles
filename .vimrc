scriptencoding 'utf-8'

let g:is_remora_cx = hostname() == 'remora.cx'
let g:is_remora = hostname() =~ '^remora'
let g:is_backup = hostname() == 'backup.remora.cx'
let g:is_office = len($H) > 0 && has('unix')
let g:is_office_win = len($USERDOMAIN) && has('win32')
let g:is_office_cygwin = len($USERDOMAIN) && has('win32unix')
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
call s:loadrc('vundle')
" マッピング
call s:loadrc('map')
" オプション設定
call s:loadrc('set')
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

" 無効化したもの
"call s:loadrc('disabled')
" ステータスバー設定
"call s:loadrc('statusbar')
" タブ設定
"call s:loadrc('tab')

