autoload -Uz throw

# Pecoでちょっとリッチなgitブランチ選択 - Qiita
# http://qiita.com/ymorired/items/1772d3112573179b68cb
function peco-git-branch() {
    local current_buffer=$BUFFER

    # commiterdate:relativeを commiterdate:localに変更すると普通の時刻表示
    local selected_line="$(git for-each-ref --format='%(refname:short) | %(committerdate:relative) | %(committername) | %(subject)' --sort=-committerdate refs/heads refs/remotes \
        | column -t -s '|' \
        | peco \
        | head -n 1 \
        | awk '{print $1}')"
    if [ -n "$selected_line" ]; then
        BUFFER="${current_buffer} ${selected_line}"
        CURSOR=$#BUFFER
        # ↓そのまま実行の場合
        #zle accept-line
    fi
    zle clear-screen
}
zle -N peco-git-branch
bindkey '^x^b' peco-git-branch

function peco-git-remote() {
  git remote | peco --prompt "GIT REMOTE>" | awk "{print $1}"
}
zle -N peco-git-remote
bindkey '^x^r' peco-git-remote

function peco-git-remote-branch() {
  git branch -a | peco --query "remotes/ " --prompt "GIT REMOTE BRANCH>" | head -n 1 | sed "s/remotes\/[^\/]*\/\(\S*\)/\1 \0/"
}
zle -N peco-git-remote-branch
bindkey '^x^e' peco-git-remote-branch

function peco-git-hash() {
  git log --oneline --branches | peco | awk "{print $1}"
}
zle -N peco-git-hash
bindkey '^x^h' peco-git-hash

function peco-git-file() {
  git status --short | peco | awk "{print $2}"
}
zle -N peco-git-file
bindkey '^x^f' peco-git-file

# open url for git repository
function peco-git-open() {
  if [ -n "$LC_FSSH_PORT" ]; then
    BUFFER="trying to open urls with FSSH"
  elif [ -n "$SSH_CLIENT" ]; then
    local host=$(echo $SSH_CLIENT | sed 's/\s.*//')
    BUFFER="trying to open urls in $host"
  fi
  local selected_url="$(git remote -v | grep '(fetch)' | ruby -ne '
    remote = $_.split(/\s+/)[1]
    if remote =~ %r[\A(?:(?:git|ssh)://)?(?!https?://)(?:[-\w]+@)?([-\w.]+)[:/](.*)\z]
      remote = "https://#$1/#$2"
    end
    puts remote
    ' | peco --prompt "OPEN REPOSITORY>")"
  if [ -n "$selected_url" ]; then
    if [ -n "$LC_FSSH_PORT" ]; then
      BUFFER="ssh -l $LC_FSSH_USER -p $LC_FSSH_PORT localhost 'open $selected_url'"
    elif [ -n "$SSH_CLIENT" ]; then
      BUFFER="ssh $host 'open $selected_url'"
    else
      BUFFER="open ${selected_url}"
    fi
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-git-open
bindkey '^x^o' peco-git-open
