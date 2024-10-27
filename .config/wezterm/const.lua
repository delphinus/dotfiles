local wezterm = require "wezterm"
local homebrew_path = wezterm.target_triple:match "^x86_64" and "/usr/local" or "/opt/homebrew"

local function detect_file(filename)
  local f = io.open(filename, "r")
  return f and f:close() and filename or false
end

return {
  url_regex = [[https?://[^<>"\s{-}\^⟨⟩`│⏎]+]],
  hash_regex = [=[[a-f\d]{4,}|[A-Z_]{4,}]=],
  path_regex = [[~?(?:[-.\w]*/)+[-.\w]*]],
  fish = detect_file(homebrew_path .. "/bin/fish") or "/usr/bin/fish",
  op = homebrew_path .. "/bin/op",
  jq = homebrew_path .. "/bin/jq",
}
