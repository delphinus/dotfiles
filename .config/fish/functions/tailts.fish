function tailts -w tail -d "Follow a file with tail, prefixing each line with a timestamp and the delta from the previous line"
    set -l opts
    # 行数指定が無ければ末尾 0 行から追従する。ts が打つのは「行を読んだ
    # 時刻」なので、既存の行にまで「今」の時刻が付くのを避ける。
    if not string match -qr -- '^(-[nc]|--lines|--bytes)' $argv
        set opts -n 0
    end

    if isatty stdout; and command -s grc > /dev/null
        # grc に本文を色付けさせる。どの conf が当たるかはコマンドライン
        # 全体へのマッチで決まるので、*.log を追うときは conf.log になる。
        #
        # --colour=on と PYTHONUNBUFFERED は両方必須。grc は stdout が端末
        # でないと (1) 色を落とし (2) python がブロックバッファして
        # tail -F の追従が出てこなくなる。ここでは必ずパイプに繋ぐ。
        PYTHONUNBUFFERED=1 command grc --colour=on tail -F $opts $argv | prefix_timestamp
    else
        command tail -F $opts $argv | prefix_timestamp
    end
end
