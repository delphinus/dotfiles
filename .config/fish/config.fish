if status is-interactive
  function assert_user_paths --description 'assert $fish_user_paths contains the path'
    for i in $argv
      if not contains $i $fish_user_paths
        if test -d $i
          set -U fish_user_paths $i $fish_user_paths
        end
      end
    end
  end

  assert_user_paths \
    ~/bin \
    ~/.cargo/bin \
    ~/.local/bin \
    ~/.ghg/bin \
    ~/.go/bin \
    ~/local/nvim/bin \
    ~/git/dotfiles/bin \
    ~/Library/Python/3.7/bin \
    ~/.gem/ruby/2.3.0/bin \
    /usr/local/opt/llvm/bin/

  set gcsdk_path /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk
  if test -d $gcsdk_path
    source "$gcsdk_path/path.fish.inc"
    bass source "$gcsdk_path/completion.bash.inc"
  end

  set nord0 2e3440
  set nord1 3b4252
  set nord2 434c5e
  set nord3 4c566a
  set nord4 d8dee9
  set nord5 e5e9f0
  set nord6 eceff4
  set nord7 8fbcbb
  set nord8 88c0d0
  set nord9 81a1c1
  set nord10 5e81ac
  set nord11 bf616a
  set nord12 d08770
  set nord13 ebcb8b
  set nord14 a3be8c
  set nord15 b48ead

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

  alias git hub
  alias g git
  alias gf 'git foresta | less'
  alias gfa 'git foresta --all | less'

  alias l. 'l -d .*'
  alias nvr 'nvr -cc split'
  alias dircolors gdircolors

  test "$fish_key_bindings" != 'fish_hybrid_key_bindings'
    and fish_hybrid_key_bindings

  set FZF_DEFAULT_OPTS '--border --inline-info --prompt="❯❯❯ " --height=40%'
  bind \c] fzf_ghq
  bind -M insert \c] fzf_ghq

  bind \ct fzf_z
  bind -M insert \ct fzf_z

  # TODO: contribute?
  bind -m insert cf begin-selection forward-jump kill-selection end-selection
  bind -m insert ct begin-selection forward-jump backward-selection end-selection
  bind -m insert cF begin-selection backward-jump kill-selection end-selection
  bind -m insert cT begin-selection backward-jump backward-selection end-selection

  direnv hook fish | source

  set -x EDITOR nvim
  set -x GIT_EDITOR nvim
  set -x VISUAL nvim

  # from prezto
  set -l e (printf "\e")
  set -x LESS_TERMCAP_mb $e'[01;31m'      # Begins blinking.
  set -x LESS_TERMCAP_md $e'[01;31m'      # Begins bold.
  set -x LESS_TERMCAP_me $e'[0m'          # Ends mode.
  set -x LESS_TERMCAP_se $e'[0m'          # Ends standout-mode.
  set -x LESS_TERMCAP_so $e'[00;47;30m'   # Begins standout-mode.
  set -x LESS_TERMCAP_ue $e'[0m'          # Ends underline.
  set -x LESS_TERMCAP_us $e'[01;32m'      # Begins underline.
  set -x LESS '-g -i -M -R -S -W -z-4 -x4 +3'

  set -x GOPATH $HOME/.go
  set -x GO111MODULE on

  if test -f ~/.config/fish/config-local.fish
    source ~/.config/fish/config-local.fish
  end

  if type -q plenv > /dev/null
    . (plenv init -|psub)
  end
end
