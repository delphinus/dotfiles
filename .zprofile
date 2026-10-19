# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/jinnouchi.yasushi/.docker/bin"
# End of Docker Desktop section.

#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

export EDITOR='nano'
export VISUAL='nano'
export PAGER='less'

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
  /usr/local/{bin,sbin}
  $path
)

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

#
# Environment
#

# 端末のどこでも効かせたい環境変数。ansible が secrets.yml の secret_env から
# 生成する (fish 側は ~/.config/fish/conf.d/00-env.fish が同じ内容を持つ)。
# zsh を対話シェルとして使ってはいないが、Claude Code の Bash ツールのように
# fish を経由せず起動される sh 系プロセスがあるので、こちらにも要る。
if [[ -f "$HOME/.config/env.sh" ]]; then
  source "$HOME/.config/env.sh"
fi

#
# Less
#

# The default Less options (LESS) live in ~/.config/lesskey, which less reads
# on its own regardless of the shell.

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

#
# Temporary Files
#

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

#
# pip のクールダウン
#

# 本体は ~/.config/pip/pip.conf の uploaded-prior-to で、シェルを問わず効く。
# 同じ値をここにも置くのは、勤務先が jamf で配っているスクリプト
# (SupplyChainAttackProtectScript) がこの行の有無だけを見て、無ければ足し直す
# ため。消すと毎回 .zprofile に差分が出る。
export PIP_UPLOADED_PRIOR_TO=P7D
