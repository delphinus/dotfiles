not status is-interactive; and exit 0

set -l paths \
  ~/bin \
  ~/.cargo/bin \
  ~/.local/bin \
  ~/.ghg/bin \
  ~/.go/bin \
  ~/local/nvim/bin \
  ~/git/dotfiles/bin \
  ~/Library/Python/3.9/bin \
  ~/.gem/ruby/2.7.0/bin \
  /usr/local/opt/ruby/bin \
  /usr/local/opt/llvm/bin \
  /usr/local/opt/perl/bin

if test "$paths" != "$fish_user_paths"
  set -U fish_user_paths $paths
end

set -l nord0 2e3440
set -l nord1 3b4252
set -l nord2 434c5e
set -l nord3 4c566a
set -l nord4 d8dee9
set -l nord5 e5e9f0
set -l nord6 eceff4
set -l nord7 8fbcbb
set -l nord8 88c0d0
set -l nord9 81a1c1
set -l nord10 5e81ac
set -l nord11 bf616a
set -l nord12 d08770
set -l nord13 ebcb8b
set -l nord14 a3be8c
set -l nord15 b48ead

set fish_color_normal $nord4
set fish_color_command $nord9
set fish_color_quote $nord14
set fish_color_redirection $nord9
set fish_color_end $nord6
#set fish_color_error $nord11
set fish_color_error $nord12
set fish_color_param $nord4
set fish_color_comment $nord3
set fish_color_match $nord8
set fish_color_search_match $nord8
set fish_color_operator $nord9
set fish_color_escape $nord13
set fish_color_cwd $nord8
#set fish_color_autosuggestion $nord6
set fish_color_autosuggestion $nord3
set fish_color_user $nord4
set fish_color_host $nord9
set fih_color_cancel $nord15
set fish_pager_color_prefix $nord13
set fish_pager_color_completion $nord6
set fish_pager_color_description $nord10
set fish_pager_color_progress $nord12
set fish_pager_color_secondary $nord1s

alias cp 'cp -i'
alias ln 'ln -i'
alias mv 'mv -i'
alias rm 'rm -i'

alias g git
alias gf 'git foresta | less'
alias gfa 'git foresta --all | less'
alias l. 'l -d .*'
alias nvr 'nvr -cc split'
alias pe path-extractor

type -q hub; and alias git hub
type -q gdircolors; and alias dircolors gdircolors

test "$fish_key_bindings" != 'fish_hybrid_key_bindings'; and fish_hybrid_key_bindings

set FZF_DEFAULT_OPTS '--border --inline-info --prompt="❯❯❯ " --height=40%'
bind \c] fzf_ghq
bind -M insert \c] fzf_ghq
bind \cx\c] 'fzf_ghq --insert'
bind -M insert \cx\c] 'fzf_ghq --insert'

bind \cxf fzf_git_status
bind -M insert \cxf fzf_git_status
bind \cx\cf 'fzf_git_status --editor'
bind -M insert \cx\cf 'fzf_git_status --editor'

bind \cxo __fzf_find_file
bind -M insert \cxo __fzf_find_file
bind \cx\co '__fzf_open --editor'
bind -M insert \cx\co '__fzf_open --editor'

bind \ct fzf_z
bind -M insert \ct fzf_z
bind \cx\ct 'fzf_z --insert'
bind -M insert \cx\ct 'fzf_z --insert'

# TODO: contribute?
bind -m insert cf begin-selection forward-jump kill-selection end-selection
bind -m insert ct begin-selection forward-jump backward-char kill-selection end-selection
bind -m insert cF begin-selection backward-jump kill-selection end-selection
bind -m insert cT begin-selection backward-jump forward-char kill-selection end-selection

if type -q floaterm
  alias f floaterm
  set -x EDITOR floaterm
  set -x GIT_EDITOR nvim
  set -x VISUAL floaterm
else
  set -x EDITOR nvim
  set -x GIT_EDITOR nvim
  set -x VISUAL nvim
end
if type -q bat
  set -x PAGER bat
  set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

# from prezto
set -x LESS_TERMCAP_mb \e'[01;31m'      # Begins blinking.
set -x LESS_TERMCAP_md \e'[01;31m'      # Begins bold.
set -x LESS_TERMCAP_me \e'[0m'          # Ends mode.
set -x LESS_TERMCAP_se \e'[0m'          # Ends standout-mode.
set -x LESS_TERMCAP_so \e'[00;47;30m'   # Begins standout-mode.
set -x LESS_TERMCAP_ue \e'[0m'          # Ends underline.
set -x LESS_TERMCAP_us \e'[01;32m'      # Begins underline.
set -x LESS '-g -i -M -R -S -W -z-4 -x4 +3'

set -x GOPATH $HOME/.go
set -x GO111MODULE on

set -x PYTHONPATH \
  ./src \
  ./rplugin/python3 \
  $HOME/.cache/dein/repos/github.com/Shougo/defx.nvim/rplugin/python3 \
  $HOME/.cache/dein/repos/github.com/Shougo/denite.nvim/rplugin/python3 \
  $HOME/.cache/dein/repos/github.com/Shougo/deol.nvim/rplugin/python3 \
  $HOME/.cache/dein/repos/github.com/Shougo/deoplete.nvim/rplugin/python3 \
  /usr/local/Cellar/fontforge/*/lib/python3.9/site-packages
set -x MYPYPATH $PYTHONPATH

set gcsdk_path /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk
if test -d $gcsdk_path
  source "$gcsdk_path/path.fish.inc"
  bass source "$gcsdk_path/completion.bash.inc"
end

type -q direnv; and direnv hook fish | source
type -q gosshauth; and gosshauth hook fish | source
type -q plenv; and source (plenv init -| psub)
type -q goenv; and source (goenv init -| psub)
type -q nodenv; and source (nodenv init -| psub)

test -f ~/.config/fish/config-local.fish; and source ~/.config/fish/config-local.fish

# TODO: Now google-cloud-sdk does not work with Python 3.9!
set -x CLOUDSDK_PYTHON /usr/local/opt/python@3.8/bin/python3
