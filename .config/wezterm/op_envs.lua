local const = require "const"
local wezterm = require "wezterm"

return function(envs)
  local filename = "/tmp/.1password-env"
  if #wezterm.glob(filename) == 0 then
    os.execute(
      ([[%s --vault CLI item get --format json secret_envs | %s -r '.fields[] | select(.value) | "\(.label)=\(.value)"' > %s]]):format(
        const.op,
        const.jq,
        filename
      )
    )
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
