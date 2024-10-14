local const = require "const"
local wezterm = require "wezterm"

return function(envs)
  local filename = "/tmp/.1password-env"
  if #wezterm.glob(filename) == 0 then
    wezterm.log_warn "envs from op are not found"
    return envs
  end
  local file = io.open(filename)
  assert(file, "op_secrets exists")

  for line in file:lines() do
    for key, value in line:gmatch "([^=]+)=([^=]+)" do
      envs[key] = value
    end
  end
  return envs
end
