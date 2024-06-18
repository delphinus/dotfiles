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

set -l nord0 2e3440 # #2e3440
set -l nord1 3b4252 # #3b4252
set -l nord2 434c5e # #434c5e
set -l nord3 4c566a # #4c566a
set -l nord4 d8dee9 # #d8dee9
set -l nord5 e5e9f0 # #e5e9f0
set -l nord6 eceff4 # #eceff4
set -l nord7 8fbcbb # #8fbcbb
set -l nord8 88c0d0 # #88c0d0
set -l nord9 81a1c1 # #81a1c1
set -l nord10 5e81ac # #5e81ac
set -l nord11 bf616a # #bf616a
set -l nord12 d08770 # #d08770
set -l nord13 ebcb8b # #ebcb8b
set -l nord14 a3be8c # #a3be8c
set -l nord15 b48ead # #b48ead

set fish_color_normal $nord4 # #d8dee9
set fish_color_command $nord9 # #81a1c1
set fish_color_quote $nord14 # #a3be8c
set fish_color_redirection $nord9 # #81a1c1
set fish_color_end $nord6 # #eceff4
#set fish_color_error $nord11 # #bf616a
set fish_color_error $nord12 # #d08770
set fish_color_param $nord4 # #d8dee9
set fish_color_comment $nord3 # #4c566a
set fish_color_match $nord8 # #88c0d0
set fish_color_search_match $nord8 # #88c0d0
set fish_color_operator $nord9 # #81a1c1
set fish_color_escape $nord13 # #ebcb8b
set fish_color_cwd $nord8 # #88c0d0
#set fish_color_autosuggestion $nord6 # #eceff4
set fish_color_autosuggestion $nord3 # #4c566a
set fish_color_user $nord4 # #d8dee9
set fish_color_host $nord9 # #81a1c1
set fih_color_cancel $nord15 # #b48ead
set fish_pager_color_prefix $nord13 # #ebcb8b
set fish_pager_color_completion $nord6 # #eceff4
set fish_pager_color_description $nord10 # #5e81ac
set fish_pager_color_progress $nord12 # #d08770
set fish_pager_color_secondary $nord1 # #3b4252

set hydro_color_duration $nord13 # #ebcb8b
set hydro_color_error $nord12 # #d08770
set hydro_color_git $nord14 # #a3be8c
set hydro_color_pwd $nord10 # #5e81ac
set hydro_fetch true
set hydro_symbol_prompt \e'[1;31m'❱\e'[1;33m'❱\e'[1;32m'❱\e'[m'

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

type -q hub; and alias git hub
abbr dircolors gdircolors

eval (gdircolors -c ~/.dir_colors)

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
set -x LESS '-g -i -M -R -S -W -z-4 -x4 +
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
    set path (type -P luarocks)
    set filename $HOME/.local/var/cache/(string replace -a / - $path)
    set timestamp 0
    test -f $filename; and set timestamp (cat $filename)
    set t (stat -f %m $path)
    if test $t -gt $timestamp
        set completion $HOME/.config/fish/completions/luarocks.fish
        mkdir -p (dirname $completion)
        luarocks completion fish >$completion
        mkdir -p (dirname $filename)
        echo $t >$filename
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

abbr alacritty $HOME/Applications/Alacritty.app/Contents/MacOS/alacritty
if test -n "$NVIM"
    set -x EXA_ICON_SPACING 1
else
    set -x EXA_ICON_SPACING 2
end
alias l 'eza -lF --group-directories-first --color-scale --icons --time-style long-iso --git'

set -x EZA_COLORS 'da=38;2;143;191;187'

set alacritty_resource $HOME/Applications/Alacritty.app/Contents/Resources
if test -d $alacritty_resource
    contains $alacitty_resource $MANPATH; or set -x MANPATH $MANPATH:$alacritty_resource
    set alacritty_man1 $alacritty_resource/man1
    set alacritty_man5 $alacritty_resource/man5
    if ! test -d $alacritty_man1
        mkdir $alacritty_man1
        mkdir $alacritty_man5
        pushd $alacritty_man1
        ln -s ../alacritty.1.gz
        ln -s ../alacritty-msg.1.gz
        popd
        pushd $alacritty_man5
        ln -s ../alacritty.5.gz
        ln -s ../alacritty-bindings.5.gz
        popd
    end
end
