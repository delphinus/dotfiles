function __source_cached --description 'コマンドの出力をキャッシュしてから source する'
    # 使い方: __source_cached <名前> <依存ファイル>... -- <コマンド>...
    #
    # `foo init fish | source` のような初期化は、毎回コマンドを起動するぶん
    # 新しいタブで fish が使えるまでが遅くなる。出力が依存ファイルだけで
    # 決まるものはキャッシュしておき、依存ファイルの実体のパスか mtime が
    # 変わったときだけ作り直す。パスも見るのは、Homebrew の更新で Cellar の
    # 版のディレクトリが変わっても、bottle の mtime が古いままのことがあるため。
    set -l sep (contains -i -- -- $argv); or return 1
    set -l name $argv[1]
    set -l deps $argv[2..(math $sep - 1)]
    set -l cmd $argv[(math $sep + 1)..]

    set -l resolved (path resolve $deps)
    set -l key "# key: "(string join ' ' $resolved (path mtime $resolved))
    set -l cache ~/.cache/fish/source-cached/$name.fish

    # 外部コマンド (head 等) を起動するだけで数十 ms かかるので、組み込みの read で読む
    if test -f $cache; and read -l first <$cache; and test "$first" = "$key"
        source $cache
        return
    end

    set -l out ($cmd | string collect)
    or begin
        # 失敗したときはキャッシュを書かず、出た分だけ流す
        printf '%s\n' $out | source
        return 1
    end
    mkdir -p (path dirname $cache)
    # 複数のタブが同時に起動しても書きかけを読まないよう、別名で書いてから置き換える
    printf '%s\n%s\n' $key $out >$cache.$fish_pid
    and command mv -f $cache.$fish_pid $cache
    printf '%s\n' $out | source
end
