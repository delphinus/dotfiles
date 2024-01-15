local wezterm = require "wezterm"
local homebrew_path = wezterm.target_triple:match "^x86_64" and "/usr/local" or "/opt/homebrew"

return {
  url_regex = [[https?://[^<>"\s{-}\^⟨⟩`│⏎]+]],
  hash_regex = [=[[a-f\d]{4,}|[A-Z_]{4,}]=],
  path_regex = [[~?(?:[-.\w]*/)+[-.\w]*]],
  tmux_run_bin = "/Users/jinnouchi.yasushi/git/dotfiles/bin/tmux-run",
  fish_bin = homebrew_path .. "/bin/fish",
  tmux_bin = homebrew_path .. "/bin/tmux",
}
