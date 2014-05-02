" QFixMemo 設定
if is_vm
    let g:dropbox_dir='/mnt/hgfs/Dropbox'
elseif is_xerxes
    let g:dropbox_dir='D:/Dropbox'
elseif is_xerxes_cygwin
    let g:dropbox_dir='/d/Dropbox'
elseif is_office_win
    let g:dropbox_dir='C:/Dropbox'
elseif is_office_cygwin
    let g:dropbox_dir='/c/Dropbox'
elseif is_remora
    let g:dropbox_dir='/Users/delphinus/Dropbox'
elseif is_backup
    let g:dropbox_dir='/home/delphinus/Dropbox'
endif

" キーマップリーダー
let QFixHowm_Key='g'
" ファイル保存用
if is_office_win || is_office_cygwin || is_remora || is_backup || is_vm
    let howm_dir=g:dropbox_dir . '/Write'
elseif is_office
    let howm_dir=expand('$H') . '/howm'
endif

" ファイル名
let howm_filename='%Y/%m/%Y-%m-%d-%H%M%S.txt'
" ファイルのエンコーディング
let howm_fileencoding='utf-8'
" ファイルの改行コード
let howm_fileformat='dos'
" ファイル形式は howm_memo + markdown
let QFixHowm_FileType='howm_memo.markdown'
" ファイルの拡張子
let QFixHowm_FileExt='txt'
" 日記ファイル名
let QFixHowm_DiaryFile='%Y/%m/%Y-%m-%d-000000.txt'
" grep の指定
if is_office_win
    let mygrepprg='c:/cygwin/bin/grep.exe'
    let MyGrep_cygwin17=1
elseif is_office || is_backup
    let mygrepprg='/bin/grep'
else
    let mygrepprg='/usr/bin/grep'
endif
" プレビュー無効
let g:QFix_PreviewEnable=0

" QfixMemo 保存前実行処理
" BufWritePre
function! QFixMemoBufWritePre()
  " タイトル行付加
  call qfixmemo#AddTitle()
  " タイムスタンプ付加
  call qfixmemo#AddTime()
  " タイムスタンプアップデート
  call qfixmemo#UpdateTime()
  " Wikiスタイルのキーワードリンク作成
  call qfixmemo#AddKeyword()
  " ファイル末の空行を削除
  call qfixmemo#DeleteNullLines()
endfunction

" カレンダーの休日予定
let QFixHowm_HolidayFile=g:bundle_dir . '/qfixhowm_with-watchdogs/misc/holiday/Sche-Hd-0000-00-00-000000.utf8'
" カレンダーの休日マークを隠す
highlight CalConceal ctermfg=8
" カレンダー表示の日本語化
let g:calendar_jp=2
" カレンダーの表示月数
let g:QFixHowm_CalendarCount=6

"-----------------------------------------------------------------------------
" 一つ分のエントリを選択
function! s:QFixSelectOneEntry()
    " save cursor position
    let save_cursor = getpos('.')

    JpJoinAll
    call QFixMRUMoveCursor('prev')
    let start = getpos('.')
    call QFixMRUMoveCursor('next')
    let end = getpos('.')
    let lines = getline(start[1] + 1, end[1] - 2)
    let @" = join(lines, "\n")
    normal u

    " restore cursor position
    call setpos('.', save_cursor)
endfunction

noremap <silent> <Plug>(qfixhowm-select_one_entry) :<C-U>call <SID>QFixSelectOneEntry()<CR>
nmap g,S <Plug>(qfixhowm-select_one_entry)

"-----------------------------------------------------------------------------
" 一つ前と同じタイトルでエントリを作成
function! s:QFixCopyTitleFromPrevEntry()
    let save_register = @"

    call QFixMRUMoveCursor('prev')
    let title = getline('.')
    let title = substitute(title, '^= ', '', '')
    let @" = title
    call QFixMRUMoveCursor('next')
    call qfixmemo#Template('next')
    stopinsert
    normal! p
    normal! o
    startinsert

    let @" = save_register
endfunction

noremap <silent> <Plug>(qfixhowm-copy_title_from_prev_entry) :<C-U>call <SID>QFixCopyTitleFromPrevEntry()<CR>
nmap g,M <Plug>(qfixhowm-copy_title_from_prev_entry)

"-----------------------------------------------------------------------------
" http://stackoverflow.com/questions/12325291/parse-a-date-in-vimscript
function! AdjustDate(date, offset)
    python <<EOP
import vim
import datetime

result = datetime.datetime.strptime(vim.eval('a:date'), '%Y-%m-%d') + \
    datetime.timedelta(days=int(vim.eval('a:offset')))
vim.command("let l:result = '" + result.strftime('%Y-%m-%d') + "'")
EOP

    return result
endfunction

" 日記移動
function! s:QFixMoveAroundDiaries(direction)
    let filename = expand('%:p:r')
    let ext = expand('%:e')
    let ymd = matchstr(filename,
                \ '\c\v^' . g:howm_dir . '/\d+/\d+/\zs\d+-\d+-\d+\ze-\d+$')
    if ymd == ''
        echom 'this is not qfixhowm file.'
        return
    endif

    let try_max = 30
    let new_filename = ''
    for try_count in range(1, try_max)
        let new_ymd = AdjustDate(ymd, try_count * a:direction)
        let new_date = matchlist(new_ymd, '\v(\d+)-(\d+)-\d+')
        let tmp_filename = printf('%s/%04d/%02d/%s-000000.%s',
                    \ g:howm_dir, new_date[1], new_date[2], new_ymd, ext)

        if filewritable(tmp_filename)
            let new_filename = tmp_filename
            break
        endif
    endfor

    if new_filename == ''
        echom 'diary is not found'
        return
    endif

    if &modified
        if exists('g:dwm_version')
            call DWM_New()
        else
            new
        endif
    endif

    execute 'edit ' . new_filename
endfunction

noremap <silent> <Plug>(qfixhowm-move_next_diary) :<C-U>call <SID>QFixMoveAroundDiaries(1)<CR>
nmap g,> <Plug>(qfixhowm-move_next_diary)
noremap <silent> <Plug>(qfixhowm-move_prev_diary) :<C-U>call <SID>QFixMoveAroundDiaries(-1)<CR>
nmap g,< <Plug>(qfixhowm-move_prev_diary)

"-----------------------------------------------------------------------------
" 半角だけの行は整形しない
let JpFormatExclude = '^[^[[:print:][:space:]]\+$'

"-----------------------------------------------------------------------------
" markdown 設定
if has('perl')
    " markdown 形式から JIRA 形式に変換する
    function! s:MarkdownToJIRA(...)
        if !a:0
            call s:QFixSelectOneEntry()
        endif

    perl <<EOP
        use Encode;
        use IO::Handle;
        use Path::Class;

        $_ = decode(utf8 => VIM::Eval('@"'));

        # タイトルを削除
        s!^=.*!!;

        # 最終行のタイムスタンプを削除
        s!^\[\d{4}-\d\d-\d\d \d\d:\d\d]\n\n?\z!!m;

        # <H> タグ変換
        s!^(#+) (.*)!'h' . length($1) . ". $2"!egm;

        # リンクを変換
        my $url = qr!(?:(?:ht|f)tps?|mailto)://[-=.,:?&;%#/\w\d]+!;
        s!\[($url)\]\((\S+)(?: "([^"]+)")?\)![\2|\1]!g;
        s!<($url)>![\1]!g;
        s!<([.a-zA-Z0-9]+@[.a-zA-Z0-9]+)>![mailto:\1]!g;
        s!\[([^]]+)\]\[([^]]+)\]!
            my ($desc, $name) = ($1, $2);
            my ($link) = /^\[$name\]:\s*($url)$/m;
            "[$desc|$link]";
        !eg;

        # 強調を変換
        s!\*\*(\S.*?\S)\*\*!*\1*!sg;

        # リンクを削除
        s!^\[[^]]+\]:\s*$url\n?!!mg;

        # リストを変換
        s!^  [-+*]!**!gm;
        s!^    [-+*]!***!gm;
        s!^      [-+*]!****!gm;

        # 番号付きリストを変換
        s!^\d+\. !# !gm;

        # 等幅文字を変換
        s!`([^`]+)`!{{$1}}!g;

        # コードブロックを変換
        s|(?:^\t.*\n)+|
            my $str = $&;
            $str =~ s/^\t//gm;
            my ($kind) = $str =~ /^#!(.*)\n/;
            if (0 < length $kind) {
                $str = $';
            } else {
                $kind = 'none';
            }
            "{code:$kind}\n${str}{code}\n";
        |egm;

        # 引用を変換
        s!(?:^> .*\n?)+!
            my $str = $&;
            $str =~ s/^> //gm;
            substr($str, -1, 1) eq "\n" or $str .= "\n";
            "{quote}\n${str}{quote}\n";
        !egm;

        # 画像ファイル名処理
        s!(?<=\d{4}-\d\d-\d\d)-(?=\d{6}\.(?:png|jpg))!_!g;
        s!(?<=\d{4}-\d\d-\d\d)=(?=\d{6}\.(?:png|jpg))!-!g;

        # クリップボードにセット
        my ($success, $filename) = VIM::Eval('g:y2r_config.tmp_file');
        my $fh = file($filename)->openw;
        binmode $fh => ':encoding(utf8)';
        $fh->print($_);
        $fh->close;
        VIM::DoCommand('call Yank2Remote(1)');
EOP
    endfunction

    " markdown 形式から trac 形式に変換する
    function! s:MarkdownToTrac()
        echo 1
        "call <SID>QFixSelectOneEntry()
        echo 2
    perl << EOP
        VIM::Msg(0);
        use Encode;
        #use Win32::Clipboard;
        use Path::Class;
        VIM::Msg(1);

        # 文書のエンコーディング
        #$enc = find_encoding(VIM::Eval('&fenc'));

        # バッファ全体を得る
        #$_ = join "\n", map { $cp932->encode($enc->decode($_)) }
        #$curbuf->Get(1 .. $curbuf->Count);
        #$_ = decode(utf8 => VIM::Eval('@*'));
        $_ = decode(utf8 => VIM::Eval('@"'));
        VIM::Msg($_);

        # タイトルを削除
        s!^= .*!!;

        # 最終行のタイムスタンプを削除
        s!^\[\d{4}-\d\d-\d\d \d\d:\d\d\]\n\n?!!m;

        # <H> タグ変換
        s!^(#+) (.*)!'=' x length($1) . " $2 " . '=' x length($1)!egm;

        # リンクを変換
        s!\[([^]]+)\]\((\S+)(?: "([^"]+)")?\)![\2 \1]!g;
        s!<((?:(?:ht|f)tps?|mailto)://\S+)>![\1]!g;
        s!<([.a-zA-Z0-9]+@[.a-zA-Z0-9]+)>![mailto:\1]!g;

        # リストを変換
        s!^(?=\*\s+)!  !gm;

        # 強調を変換
        s!__([^\t]+?)__!'''\1'''!g;

        # コードブロックを変換
        s!(?:^\t.*\n)+!
            my ($str = $&) =~ s/^\t//gm;
            "{{{\n$str}}}\n";
        !egmx;

        #$_ = encode(cp932 => $_);

        # クリップボードにセット
        #Win32::Clipboard()->Set($_);
        my ($success, $filename) = VIM::Eval('g:y2r_config.tmp_file');
        VIM::Msg($success);
        VIM::Msg($filename);
        my $fh = file($filename)->openw;
        VIM::Msg($_);
        $fh->binmode(':encoding(utf8)');
        $fh->print($_);
        $fh->close;
        VIM::DoCommand('call Yank2Remote(1)');

        VIM::Msg('convert markdown to trac');
EOP
        echo 'done'
    endfunction

    nnoremap <Leader>ji :<C-U>call <SID>MarkdownToJIRA()<CR>
    nnoremap <Leader>mt :<C-U>call <SID>MarkdownToTrac()<CR>
endif

function! MarkdownToMail()
    %s/\t$//
    call <SID>QFixSelectOneEntry()
    call Yank2Remote(1)
    echo 'yank to remote for mail'
endfunction

nnoremap <Leader>ma :call MarkdownToMail()<CR>
