#!/bin/sh
#should be compatible with bash zsh sh(->bash) and dash. is not with ksh

### Author: Luc
### Ideas and code partly copied from 'vimscript':
# http://www.vim.org/scripts/script.php?script_id=1349
### and '256colors2.pl':
# http://cvsweb.xfree86.org/cvsweb/xc/programs/xterm/vttests/256colors2.pl
# Todd Larason <jtl@molehill.org>
# $XFree86: xc/programs/xterm/vttests/256colors2.pl,v 1.2 2002/03/26 01:46:43 dickey Exp $
### AND mostly 'colortest':
# http://packages.debian.org/squeeze/colortest

# TODO:
# perl -e 'print map sprintf(" \x1b[38;5;%um%4u", $_, $_), 0 .. 255'

# some subroutines
##################
rep_char () {
# replacement for perls ``$char x $number''
  if [ $# -ne 2 ]; then return 1; fi
  local i=$1
  while [ $i -gt 0 ]; do printf "%s" "$2"; i=$((i-1)); done
}

system_2x8 () {
# translated from 256colors2.pl
  if $title; then echo "System colors:"; fi
  local i=0
  while [ $i -lt 8 ]; do printf "\033[48;5;${i}m  "; i=$((i+1)); done
  echo -e "\033[m"
  while [ $i -lt 16 ]; do printf "\033[48;5;${i}m  "; i=$((i+1)); done
  echo -e "\033[m"
}

cubes_6x6x6 () {  #originally g r b
# translated from 256colors2.pl
  local red=r
  local green=g
  local blue=b
  local delim=" "
  local r=
  local color=
  if [ $# -ge 2 ]; then red=${1} green=${2} blue=${3} delim="$4"
  else echo "Need an argument."; return 1
  fi
  if $title; then echo "Color cube, 6x6x6:"; fi
  for r in 0 1 2 3 4 5; do
    for g in 0 1 2 3 4 5; do
      for b in 0 1 2 3 4 5; do
        eval temp_r="\$$red"
	eval temp_b="\$$blue"
	eval temp_g="\$$green"
	color=$((16 + (temp_r * 36) + (temp_g * 6) + temp_b))
	printf "\033[48;5;${color}m  "
      done
      printf "\033[m$delim"
    done
    echo
  done
}

grayscale_24 () {
# translated from 256colors2.pl
  if $title; then echo "Grayscale ramp:"; fi
  local i=232
  while [ $i -lt 256 ]; do printf "\033[48;5;${i}m  "; i=$((i+1)); done
  printf "\033[m";
}

colorscale_6 () {
# idea from grayscale_24 of
  if [ $1 = r ]; then local factor=36
  elif [ $1 = g ]; then local factor=6
  elif [ $1 = b ]; then local factor=1
  else echo "Argument was not in \"[rgb]\"."; return 1
  fi
  local i=
  for i in 0 1 2 3 4 5; do printf "\033[48;5;$((16 + factor * i))m  "; done
  printf "\033[m"
}

list_with_rgb_values () { #rbg
# from vimscript
  delimiter1="$1";
  delimiter2="$2";
  local red
  local blue
  local green
  for red in 0 1 2 3 4 5; do
    for blue in 0 1 2 3 4 5; do
      for green in 0 1 2 3 4 5; do
        local color=$((16 + (red * 36) + (green * 6) + blue))
	local rgb_red=$((red * 40))
	local rgb_green=$((green * 40))
	local rgb_blue=$((blue * 40))
	rgb_red=$((rgb_red + rgb_red == 0 ? 0 : 55))
 	rgb_green=$((rgb_green + rgb_green == 0 ? 0 : 55))
 	rgb_blue=$((rgb_blue + rgb_blue == 0 ? 0 : 55))
        printf "\033[38;5;${color}m %3u: %02x/%02x/%02x${delimiter1}" $color $rgb_red $rgb_green $rgb_blue
      done
      printf "$delimiter2"
    done
  done
}

system_color_table2 () {
# from debian (versatile version)
  text="${1:-xXx}"
  size=${2:-1}
  delim=`rep_char $size ' '`
  side=
  if $title; then
    textlength=${#text}
    side=`rep_char $size ' '`
    head="$side       | ${delim}`rep_char $((textlength - 2)) ' '`0m  "
    local i=
    for i in 40 41 42 43 44 45 46 47; do
      head="$head$delim`rep_char $((textlength - 3)) ' '`  ${i}m  "
    done
    echo
    echo "$head"
    echo "$head" | sed 's/[^|]/-/g;s/|/+/'
  fi
  for fg in "" 1 30 "1;30" 31 "1;31" 32 "1;32" 33 "1;33" 34 "1;34" 35 "1;35" 36 "1;36" 37 "1;37"; do
    if $title; then printf "$side%4sm  |$delim" "$fg"; fi
    printf "\033[${fg}m $text  "
    for i in 40 41 42 43 44 45 46 47; do
      printf "$delim\033[${i}m  $text  \033[49m"
    done
    printf "\033[m\n"
  done
  if $title; then echo; fi
}

system_color_table () {
# from debian (basic version)
  local TEXT=gYw
  echo
  echo "        |   0m     40m     41m     42m     43m     44m     45m     46m     47m"
  echo " -------+-----------------------------------------------------------------------"
  for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
	     '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
	     '  36m' '1;36m' '  37m' '1;37m';
    do FG=${FGs// /}
    printf " $FGs  |\033[$FG  $TEXT  "
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
      do printf " \033[$FG\033[$BG  $TEXT  \033[0m";
    done
    echo;
  done
  echo
}

# the main routine
##################
colors=8
size=2
delimiter1=
delimiter2='\n'
title=true

#GetOptions (
#	    'small'          => sub { $size = 0 },
#	    'help'           => sub { die("help") },
#	    'list'           => sub { list_with_rgb_values $delimiter1, $delimiter2 },
#	    'long'           => sub { $delimiter1 = "\n"; $delimiter2 = "" },
#	    'scales'         => sub {grayscale_24;colorscale_6 "r";colorscale_6 "g";colorscale_6 "b"; print "\n"; exit;},
#	   );

while getopts 0123456789ac:ghlpstwx FLAG; do
  case $FLAG in
    [0-9]) size=$FLAG;;
    a) colors=256;;
    c) colors=$OPTARG;;
    g) gray=;;
    h) echo "HELP!"; exit;;
    l) list_with_rgb_values "$delimiter1" "$delimiter2"; exit;;
    p) title=false;;
    s) colors=8;;
    t) title=true;;
    w) delimiter1="    " delimiter2='\n';;
    x) set -x;;
  esac
done

if [ $colors -eq 8 ]; then
  if [ $size -eq 0 ]; then
    system_2x8
  else
    system_color_table2 "gYw" $((size - 1));
  fi
#elif [ $colors -eq 16 ]; then :
  #TODO
elif [ $colors -eq 256 ]; then
  if [ $size -eq 0 ]; then
    cubes_6x6x6 g r b ""
  elif [ $size -eq 1 ]; then
    cubes_6x6x6 "grb" " "
    grayscale_24
    echo
  elif [ $size -ge 2 ]; then
    if [ $size -ge 3 ]; then
      system_2x8
    fi
    cubes_6x6x6 g r b " "
    grayscale_24
    echo
  fi
fi
