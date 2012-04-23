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
source ~/.vim/rc/vundle.vim
" マッピング
source ~/.vim/rc/map.vim
" オプション設定
source ~/.vim/rc/set.vim
" ユーティリティ関数
source ~/.vim/rc/functions.vim

" QFixMemo 設定
source ~/.vim/rc/qfixmemo.vim
" QuickRun 設定
source ~/.vim/rc/quickrun.vim
" Perl 設定
source ~/.vim/rc/perl.vim
" Ref 設定
source ~/.vim/rc/ref.vim
" Netrw 設定
source ~/.vim/rc/netrw.vim
" Unite 設定
source ~/.vim/rc/unite.vim
" VimFiler 設定
source ~/.vim/rc/vimfiler.vim
" neocomplcache 設定
source ~/.vim/rc/neocomplcache.vim
" VimShell 設定
source ~/.vim/rc/vimshell.vim
" Powerline 設定
source ~/.vim/rc/powerline.vim
" JpFormat 設定
source ~/.vim/rc/jpformat.vim
" TweetVim 設定
source ~/.vim/rc/tweetvim.vim
" Gist 設定
source ~/.vim/rc/gist.vim
" jsl 設定
source ~/.vim/rc/jsl.vim
" DrawIt 設定
source ~/.vim/rc/drawit.vim
" Chalice 設定
source ~/.vim/rc/chalice.vim
" vim-funlib 設定
source ~/.vim/rc/funlib.vim
" errormarker 設定
source ~/.vim/rc/errormarker.vim
" EasyMotion 設定
source ~/.vim/rc/easymotion.vim
" YankRing 設定
source ~/.vim/rc/yankring.vim
" cmdline-completion 設定
source ~/.vim/rc/cmdline-completion.vim
" シンタックスチェック
source ~/.vim/rc/syntastic.vim
" http://d.hatena.ne.jp/osyo-manga/20110921/1316605254
"source ~/.vim/rc/syntaxcheck.vim
" CSV 設定
source ~/.vim/rc/csv.vim
" markdown 設定
source ~/.vim/rc/markdown.vim
" Clam 設定
source ~/.vim/rc/clam.vim

" 無効化したもの
"source ~/.vim/rc/disabled.vim
" ステータスバー設定
"source ~/.vim/rc/statusbar.vim
" タブ設定
"source ~/.vim/rc/tab.vim

