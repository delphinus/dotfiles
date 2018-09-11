# ref https://stackoverflow.com/questions/18906460/zsh-print-array-objects-in-color-to-terminal-window
function pp-array() {
  autoload -Uz colors && colors
  local array_name=$1

  local array_length=${#${(P)${array_name}}}
  for (( i = 1; i < $array_length; i+=3 )) do
    print -P %{${fg[red]}%}${(P)${array_name}[i]}%{$reset_color             %}${(P)${array_name}[i+1]} %{${fg[yellow]}%}${(P)${array_name}[i+2]}%{$reset_color%}
  done
}
