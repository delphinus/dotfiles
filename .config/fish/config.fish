not status is-interactive; and exit 0

set -l homebrew_path
if test -d /opt/homebrew
    # avoid the homebrew bin path to set above all of paths
    /opt/homebrew/bin/brew shellenv | grep -v 'set PATH' | source
    set homebrew_path /opt/homebrew
else
    set -x HOMEBREW_PREFIX /usr/local
    set homebrew_path /usr/local
end

set -l paths \
    ~/bin \
    ~/.luarocks/bin \
    ~/.cargo/bin \
    ~/.local/bin \
    ~/.ghg/bin \
    ~/.go/bin \
    ~/git/dotfiles/bin \
    ~/Library/Python/3.11/bin \
    ~/Library/Python/3.9/bin \
    ~/.gem/ruby/3.2.0/bin \
    $homebrew_path/opt/git/share/git-core/contrib/git-jump \
    $homebrew_path/opt/ruby/bin \
    $homebrew_path/opt/llvm/bin \
    $homebrew_path/opt/perl/bin \
    $homebrew_path/opt/libiconv/bin \
    $homebrew_path/opt/rakudo-star/share/perl6/site/bin \
    /Applications/Xcode.app/Contents/Developer/usr/bin \
    ~/Library/Application\ Support/Coursier/bin \
    $homebrew_path/sbin \
    $homebrew_path/bin \
    /usr/local/bin
# ↑/usr/local/bin is included both in Homebrew of both arm & x86 version

test "$paths" != "$fish_user_paths"; and set -U fish_user_paths $paths

set -l theme ~/.local/share/nvim/lazy/sweetie.nvim/extras/fish/Sweetie\ Dark.theme
# set -l theme ~/.local/share/nvim/lazy/sweetie.nvim/extras/fish/Sweetie\ Light.theme
if test -f $theme
    string replace -rf '^fish' 'set $0' <$theme | source
end

set __fish_git_prompt_showuntrackedfiles true
set __fish_git_prompt_showcolorhints true

# These are extremely slow
#set __fish_git_prompt_showdirtystate true
#set __fish_git_prompt_showstashstate true
#set __fish_git_prompt_showupstream auto
#set __fish_git_prompt_show_informative_status true

set __fish_git_prompt_char_cleanstate ✓
set __fish_git_prompt_char_dirtystate ∑
set __fish_git_prompt_char_invalidstate ✗
set __fish_git_prompt_char_stagedstate ●
set __fish_git_prompt_char_stashstate ∏
set __fish_git_prompt_char_stateseparator ❘
set __fish_git_prompt_char_untrackedfiles …
set __fish_git_prompt_char_upstream_ahead ↑
set __fish_git_prompt_char_upstream_behind ↓
set __fish_git_prompt_char_upstream_diverged ≠
set __fish_git_prompt_char_upstream_equal =
set __fish_git_prompt_char_upstream_prefix ''

alias cp 'cp -i'
alias ln 'ln -i'
alias mv 'mv -i'
alias rm 'rm -i'

abbr g git
abbr gf 'git foresta | less'
abbr gfa 'git foresta --all | less'
abbr l. 'l -d .*'
abbr ta 'tig --all'

type -q hub; and alias git hub
if type -q gdircolors
    abbr dircolors gdircolors
    eval (gdircolors -c ~/.dir_colors)
else
    eval (dircolors -c ~/.dir_colors)
end

if test "$NVIM_LISTEN_ADDRESS" != ''
    alias nvr 'nvr -cc \'ToggleTerm\' -cc split'
else if test "$NVIM" != ''
    alias nvr 'nvr --servername '$NVIM' -cc \'ToggleTerm\' -cc split'
end

test "$fish_key_bindings" != fish_hybrid_key_bindings; and fish_hybrid_key_bindings

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

# for Neovim
set -x EDITOR minivim
set -x GIT_EDITOR minivim
set -x VISUAL minivim

set -x PAGER less
set -x DELTA_PAGER less

# for less
# from prezto
set -x LESS_TERMCAP_mb \e'[01;31m' # Begins blinking.
set -x LESS_TERMCAP_md \e'[01;31m' # Begins bold.
set -x LESS_TERMCAP_me \e'[0m' # Ends mode.
set -x LESS_TERMCAP_se \e'[0m' # Ends standout-mode.
set -x LESS_TERMCAP_so \e'[00;47;30m' # Begins standout-mode.
set -x LESS_TERMCAP_ue \e'[0m' # Ends underline.
set -x LESS_TERMCAP_us \e'[01;32m' # Begins underline.
set -x LESS '-g -i -M -R -S -W -z-4 -x4 --mouse --wheel-lines 3 +
3'

# use Neovim for man
set -x MANWIDTH 80
set -x MANPAGER 'env MINIMAL=1 nvim --clean +"set smartcase | set ignorecase | set laststatus=0" +Man! +"set scroll=3"'

# for Lua
#set -x LUA_PATH  \
#"/usr/local/Cellar/luarocks/3.7.0/share/lua/5.4/?.lua;"\
#"$HOME/.luarocks/share/lua/5.4/?.lua;"\
#"$HOME/.luarocks/share/lua/5.4/?/init.lua;"\
#"/usr/local/share/lua/5.4/?.lua;"\
#"/usr/local/share/lua/5.4/?/init.lua"
#set -x LUA_CPATH \
#"/usr/local/lib/lua/5.4/?.so;"\
#"/usr/local/lib/lua/5.4/loadall.so;"\
#"./?.so;"\
#"$HOME/.luarocks/lib/lua/5.4/?.so"

set -x GOPATH $HOME/.go
set -x GO111MODULE on

set -x PYTHONPATH \
    ./src \
    ./rplugin/python3 \
    $homebrew_path/Cellar/fontforge/*/lib/python3.9/site-packages
set -x MYPYPATH $PYTHONPATH

set gcsdk_path $homebrew_path/Caskroom/google-cloud-sdk/latest/google-cloud-sdk
test -d $gcsdk_path; and source "$gcsdk_path/path.fish.inc"

type -q direnv; and direnv hook fish | source
type -q asdf; and source $homebrew_path/opt/asdf/libexec/asdf.fish

if type -q luarocks
    set luarocks_path (type -P luarocks)
    set filename $HOME/.local/var/cache/(string replace -a / - $luarocks_path)
    set timestamp 0
    if test -f $filename
        set timestamp (cat $filename)
        set t (stat -f %m $luarocks_path)
        if test $t -gt $timestamp
            set completion $HOME/.config/fish/completions/luarocks.fish
            mkdir -p (dirname $completion)
            luarocks completion fish >$completion
            mkdir -p (dirname $filename)
            echo $t >$filename
        end
    end
end

test -f ~/.config/fish/config-local.fish; and source ~/.config/fish/config-local.fish

# TODO: Now google-cloud-sdk does not work with Python 3.9!
set -x CLOUDSDK_PYTHON /usr/bin/python3
set -x CLOUDSDK_GSUTIL_PYTHON /usr/bin/python3

set -x NEXTWORD_DATA_PATH ~/.cache/nextword-data-large

# Use the latest format for Dockerfile
set -x DOCKER_BUILDKIT 1

# fish-grc removes this definition
_grc_wrap ps

# Run the light version of Neovim
if test -f ~/.light
    set -x LIGHT 1
end

if test -n "$NVIM"
    set -x EXA_ICON_SPACING 1
else
    set -x EXA_ICON_SPACING 2
end
alias l 'eza -lF --group-directories-first --color-scale --icons --time-style long-iso --git'

# https://zenn.dev/ryoppippi/articles/de6c931cc1028f
set -gx NOTIFY_ON_COMMAND_DURATION 5000
function fish_right_prompt
    if test $CMD_DURATION
        if test $CMD_DURATION -gt $NOTIFY_ON_COMMAND_DURATION
            if test -n $WEZTERM_PANE
                set -l active_pid (osascript -e 'tell application "System Events" to get the unix id of first process whose frontmost is true')
                set -l active_pane (wezterm cli list-clients --format json | jq -r ".[] | select(.pid == $active_pid) | .focused_pane_id")
                if test $WEZTERM_PANE -eq $active_pane
                    return
                end
            end
            set -l duration (bc -S2 -e $CMD_DURATION/1000)
            set -l msg (echo (history | head -1) returned $status after $duration s)
            osascript -e 'display notification "'$msg'" with title "command completed"'
        end
    end
end
