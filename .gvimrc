if is_win
	set guifont=Envy_Code_R_for_Powerline:h10
	set guifontwide=Ricty:h10
	set dir=C:\cygwin\tmp
	set backupdir=C:\cygwin\tmp
	set undodir=C:\cygwin\tmp
	set listchars=tab:»\ ,trail:¯,eol:↲,extends:»,precedes:«,nbsp:¯

	" markdown 形式から trac 形式に変換する
	if has('perl')
		function! MarkdownToTrac()
			call SelectOneEntry()
		perl << EOP
			use Encode;
			use Win32::Clipboard;

			# 文書のエンコーディング
			$enc = find_encoding(VIM::Eval('&fenc'));

			# バッファ全体を得る
			#$_ = join "\n", map { $cp932->encode($enc->decode($_)) }
			#$curbuf->Get(1 .. $curbuf->Count);
			$_ = decode(utf8 => VIM::Eval('@*'));

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
				($str = $&) =~ s/^\t//gm;
				"{{{\n$str}}}\n";
			!egmx;

			$_ = encode(cp932 => $_);

			# クリップボードにセット
			Win32::Clipboard()->Set($_);

			VIM::Msg('convert markdown to trac');
EOP
		endfunction
		nnoremap <Leader>mt :call MarkdownToTrac()<CR>
	endif

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
"colo desert-warm-256
"colo bubblegum
"colo neon-PK
"colo zenburn
"colo papayawhip
colo gummybears
