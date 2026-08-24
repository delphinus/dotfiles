function prefix_timestamp -d "Prefix each line of stdin with a timestamp and the seconds elapsed since the previous line"
    if not command -s ts > /dev/null
        echo "prefix_timestamp: ts が要ります (brew install moreutils)" >&2
        return 127
    end

    set -l fmt '%F %T'
    if set -q argv[1]
        set fmt $argv[1]
    end

    # ts は行の先頭に足すだけなので、経過秒 → 時刻の順に通して
    # 「時刻 経過秒 行」の並びにする。-m は単調増加クロック
    # (NTP の補正やサマータイムで経過秒が飛ばないように)。
    #
    # 色付けは端末に出すときだけ。ファイルやパイプに落とすときに
    # エスケープが混ざると困るし、grcat は python なので stdout が
    # 端末でないとブロックバッファして追従が流れてこなくなる。
    if isatty stdout; and command -s grcat > /dev/null
        command ts -i -m '%.s' | command ts $fmt | command grcat conf.ts
    else
        command ts -i -m '%.s' | command ts $fmt
    end
end
