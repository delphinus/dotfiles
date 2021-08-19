function nvim -d 'Launch Neovim with CSI u features'
  printf '\033[>4;1m'
  command nvim $argv
  printf '\033[>4;m'
end
