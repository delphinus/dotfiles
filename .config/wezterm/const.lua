local wezterm = require "wezterm"
local homebrew_path = wezterm.target_triple:match "^x86_64" and "/usr/local" or "/opt/homebrew"

return {
  url_regex = [[https?://[^<>"\s{-}\^⟨⟩`│⏎]+]],
  hash_regex = [=[[a-f\d]{4,}|[A-Z_]{4,}]=],
  path_regex = [[~?(?:[-.\w]*/)+[-.\w]*]],
  fish = homebrew_path .. "/bin/fish",
  op = homebrew_path .. "/bin/op",
  jq = homebrew_path .. "/bin/jq",
}
