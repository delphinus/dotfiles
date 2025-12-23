-- HACK: Command to launch `perl` should be changed in accordance with its root dir
local lines = vim.fn.readfile(vim.fs.normalize(vim.env.OFFICE_ENVRC))
local env = vim.iter(lines):fold({}, function(a, b)
  local key, value = b:match "^export ([^=]+)='(.*)'$"
  if key and value then
    a[key] = value
  end
  return a
end)

-- Check if current buffer's project uses carmel
local bufpath = vim.api.nvim_buf_get_name(0)
local use_carmel = false
if bufpath ~= "" then
  local carmel_files = vim.fs.find(".carmel/MySetup.pm", { upward = true, type = "file", path = bufpath })
  use_carmel = #carmel_files > 0
end

-- Check for shebang in the first line
local top = vim.api.nvim_buf_get_lines(0, 0, 1, false)
local shebang = top[1] and top[1]:match "^#!%s*(.-)%s*$"

-- Determine perlPath and perlParams
local perlPath = shebang or (use_carmel and "carmel" or "perl")
local perlParams = (not shebang and use_carmel) and { "exec", "perl" } or {}

return {
  settings = {
    perlnavigator = {
      perlEnv = env,
      perlPath = perlPath,
      perlParams = perlParams,
      includePaths = { "./lib", "./local/lib/perl5", "./t/lib" },
    },
  },
}
