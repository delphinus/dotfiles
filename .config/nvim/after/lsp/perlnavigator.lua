-- HACK: Command to launch `perl` should be changed in accordance with its root dir
local lines = vim.fn.readfile(vim.fs.normalize(vim.env.OFFICE_ENVRC))
local env = vim.iter(lines):fold({}, function(a, b)
  local key, value = b:match "^export ([^=]+)='(.*)'$"
  if key and value then
    a[key] = value
  end
  return a
end)

return {
  settings = {
    perlnavigator = {
      perlEnv = env,
      includePaths = { "./lib", "./local/lib/perl5", "./t/lib" },
    },
  },
}
