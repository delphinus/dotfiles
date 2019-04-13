autoload -Uz throw

# Pecoでちょっとリッチなgitブランチ選択 - Qiita
# http://qiita.com/ymorired/items/1772d3112573179b68cb
function peco-git-branch() {
    local current_buffer=$BUFFER

    # commiterdate:relativeを commiterdate:localに変更すると普通の時刻表示
    local selected_line="$(git for-each-ref --format='%(refname:short) | %(committerdate:relative) | %(committername) | %(subject)' --sort=-committerdate refs/heads refs/remotes \
        | column -t -s '|' \
        | fzf \
        | head -n 1 \
        | awk '{print $1}')"
    if [ -n "$selected_line" ]; then
        BUFFER="${current_buffer}${selected_line}"
        CURSOR=$#BUFFER
        # ↓そのまま実行の場合
        #zle accept-line
    fi
}
zle -N peco-git-branch
bindkey '^x^b' peco-git-branch

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
    ' | fzf --prompt "OPEN REPOSITORY>")"
  if [ -n "$selected_url" ]; then
    if [ -n "$LC_FSSH_PORT" ]; then
      BUFFER="ssh $LC_FSSH_COPY_ARGS -l $LC_FSSH_USER -p $LC_FSSH_PORT localhost 'open $selected_url'"
    elif [ -n "$SSH_CLIENT" ]; then
      BUFFER="ssh $host 'open $selected_url'"
    else
      BUFFER="open ${selected_url}"
    fi
    zle accept-line
  fi
}
zle -N peco-git-open
bindkey '^x^o' peco-git-open

function peco-git-ls-files() {
  local current_buffer=$BUFFER
  local selected=$(git ls-files | fzf --query "$LBUFFER")
  if [ -n "$selected" ]; then
    BUFFER="${current_buffer}${selected}"
    CURSOR=$#BUFFER
  fi
}
zle -N peco-git-ls-files
bindkey '^x^f' peco-ls-files

function peco-git-submodules() {
  local current_buffer=$BUFFER
  local selected="$(git submodule | perl -anle '
    $len = length $F[1] if $len < length $F[1];
    push @repos, [$F[1], $F[2]];
    END { printf "%-${len}s  %s\n", @$_ for @repos }
  ' | fzf | cut -d' ' -f1)"
  if [[ -n $selected ]]; then
    BUFFER="${current_buffer}${selected}"
    CURSOR=$#BUFFER
    zle accept-line
  fi
}
zle -N peco-git-submodules
bindkey '^x^s' peco-git-submodules
