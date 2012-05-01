if has('perl')
    " markdown 形式から JIRA 形式に変換する
    function! MarkdownToJIRA(...)
		if !a:0
			call SelectOneEntry()
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
        s!^(#+) (.*)!'h' . (length($1) + 1) . ". $2"!egm;

        # リンクを変換
        my $url = qr!(?:(?:ht|f)tps?|mailto)://[-.,:?&;%#/\w\d]+!;
        s!\[($url)\]\((\S+)(?: "([^"]+)")?\)![\2|\1]!g;
        s!<($url)>![\1]!g;
        s!<([.a-zA-Z0-9]+@[.a-zA-Z0-9]+)>![mailto:\1]!g;
        s!\[([^]]+)\]\[([^]]+)\]!
            my ($desc, $name) = ($1, $2);
            my ($link) = /^\[$name\]:\s*($url)$/m;
            "[$desc|$link]";
        !eg;

        # リンクを削除
        s!^\[[^]]+\]:\s*$url\n?!!mg;

        # リストを変換
        s!^  [-+*]!**!gm;
        s!^    [-+*]!***!gm;
        s!^      [-+*]!****!gm;

        # 等幅文字を変換
        s!`([^`]+)`!{{$1}}!g;

        # コードブロックを変換
        s|(?:^\t.*\n)+|
            my ($str) = $&;
            $str =~ s/^\t//gm;
            my ($kind) = $str =~ /^#!(.*)\n/;
            if (0 < length $kind) {
                $str = $';
            } else {
                $kind = 'plain';
            }
            "{code:$kind}\n${str}{code}\n";
        |egm;

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
    function! MarkdownToTrac()
        echo 1
        "call SelectOneEntry()
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

    nnoremap <Leader>ji :call MarkdownToJIRA()<CR>
    nnoremap <Leader>mt :call MarkdownToTrac()<CR>
endif

