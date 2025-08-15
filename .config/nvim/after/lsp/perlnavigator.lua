-- HACK: Command to launch `perl` should be changed in accordance with its root dir
local lines = vim.fn.readfile(vim.uv.os_homedir() .. "/.1password-perl-env")
local env = vim.iter(lines):fold({}, function(a, b)
  local key, value = b:match "^([^=]+)=(.*)$"
  if key and value then
    a[key] = value
  end
  return a
end)

local path = vim.api.nvim_buf_get_name(0)
local use_carmel = 0 < #vim.fs.find(".carmel/MySetup.pm", { upward = true, type = "file", path = path })
local top = vim.api.nvim_buf_get_lines(0, 0, 1, false)
local shebang = top[1] and top[1]:match "^#!%s*(.-)%s*$"

return {
  settings = {
    perlnavigator = {
      perlEnv = env,
      perlPath = shebang and shebang or use_carmel and "carmel" or "perl",
      perlParams = use_carmel and { "exec", "perl" } or {},
      includePaths = { "./lib", "./local/lib/perl5", "./t/lib" },
    },
  },
}
