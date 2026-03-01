function fzf_z --description 'Move with FZF + zoxide'
    set -l options 'i/insert'
    argparse $options -- $argv

    set -l result (command zoxide query --interactive -- $argv 2>/dev/null)
    or return

    if set -q _flag_insert
        commandline -i $result
    else
        cd $result
    end
    commandline -f repaint
end
