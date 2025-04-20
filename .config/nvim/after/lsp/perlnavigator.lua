---@return table<string, string>
local function perl_env()
  local filename = vim.uv.os_homedir() .. "/.1password-perl-env"
  local st, err = vim.uv.fs_stat(filename)
  if not st or err then
    vim.notify(filename .. " not found", vim.log.levels.WARN)
    return {}
  end
  local fd
  fd, err = vim.uv.fs_open(filename, "r", tonumber("644", 8))
  assert(not err, err)
  assert(fd, fd)
  local content
  content, err = vim.uv.fs_read(fd, st.size)
  assert(not err, err)
  assert(content, "content exists")
  return vim.iter(vim.gsplit(content, "\n")):fold({}, function(a, b)
    local key, value = b:match "^([^=]+)=(.*)$"
    if key and value then
      a[key] = value
    end
    return a
  end)
end

return {
  settings = {
    perlnavigator = {
      perlEnv = setmetatable({}, {
        __index = function(self, name)
          if not self.__env then
            self.__env = perl_env()
          end
          return self.__env[name]
        end,
      }),
      perlPath = "carmel",
      perlParams = { "exec", "perl" },
      includePaths = { "./lib", "./local/lib/perl5", "./t/lib" },
    },
  },
}
