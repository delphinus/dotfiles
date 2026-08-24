function tailts -w tail -d "Run tail, prefixing each line with a timestamp and the delta from the previous line"
    # 引数は tail にそのまま渡す。-f / -F / -n の既定は足さない。
    #
    # ts が打つのは「行を読んだ時刻」なので、追従を始める前から在った行には
    # すべて「今」の時刻が付く。それが邪魔なときは -n 0 を自分で付ける
    # (tailts -F -n 0 foo.log)。
    if isatty stdout; and command -s grc > /dev/null
        # grc に本文を色付けさせる。どの conf が当たるかはコマンドライン
        # 全体へのマッチで決まるので、*.log を追うときは conf.log になる。
        #
        # --colour=on と PYTHONUNBUFFERED は両方必須。grc は stdout が端末
        # でないと (1) 色を落とし (2) python がブロックバッファして
        # tail -F の追従が出てこなくなる。ここでは必ずパイプに繋ぐ。
        PYTHONUNBUFFERED=1 command grc --colour=on tail $argv | prefix_timestamp
    else
        command tail $argv | prefix_timestamp
    end
end
