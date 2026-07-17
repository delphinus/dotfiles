# codediff (config.fish の関数) の補完。引数は git diff と同種のリビジョン/範囲なので
# fish 同梱の git 補完ヘルパー __fish_git_ranges をそのまま流用する。
function __codediff_git_ranges
    # 未ロードなら一度 git 補完を走らせてヘルパー群を読み込む
    functions -q __fish_git_ranges; or complete -C 'git diff ' >/dev/null 2>&1
    __fish_git_ranges
end

complete -c codediff -f -a '(__codediff_git_ranges)'

# サブコマンド (第 1 引数のときだけ候補に出す)
complete -c codediff -f -n __fish_is_first_arg -a history -d 'File history mode'
complete -c codediff -f -n __fish_is_first_arg -a file -d 'Compare a file vs revision'
complete -c codediff -f -n __fish_is_first_arg -a dir -d 'Directory comparison mode'
complete -c codediff -f -n __fish_is_first_arg -a install -d 'Install/update the C library'
