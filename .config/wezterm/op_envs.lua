local const = require "const"

return function(envs)
  local filename = "/tmp/.1password-env"
  local file = io.open(filename)
  if not file then
    os.execute(
      ([[%s --vault CLI item get --format json secret_envs | %s -r '.fields[] | select(.value) | "\(.label)=\(.value)"' > %s]]):format(
        const.op,
        const.jq,
        filename
      )
    )
    file = io.open(filename)
  end
  assert(file, "op_secrets exists")

  for line in file:lines() do
    for key, value in line:gmatch "([^=]+)=([^=]+)" do
      envs[key] = value
    end
  end
  return envs
end
