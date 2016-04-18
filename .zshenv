#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# my setting

if [ -z "$H" ]; then
  export H=$HOME
fi

export PATH=
if [ -x /usr/libexec/path_helper ]; then
  eval `/usr/libexec/path_helper -s`
else
  export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin
fi

export PATH="\
$H/Dropbox/bin:\
$H/bin:\
$H/git/dotfiles/bin:\
$PATH"
