" markdown 形式から trac 形式に変換する
if has('perl')
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

        # 最終行のライムスタンプを削除
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
    nnoremap <Leader>mt :call MarkdownToTrac()<CR>
endif

