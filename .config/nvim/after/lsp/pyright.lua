local home_dir = function(p)
  return vim.uv.os_homedir() .. (p or "")
end
local iterm2_dir = function(p)
  return home_dir "/.config/iterm2/AppSupport/iterm2env-72/versions/3.8.6/lib/" .. (p or "")
end

return {
  settings = {
    python = {
      analysis = {
        extraPaths = {
          home_dir(),
          iterm2_dir "python38.zip",
          iterm2_dir "python3.8",
          iterm2_dir "python3.8/lib-dynload",
          iterm2_dir "python3.8/site-packages",
        },
      },
    },
  },
}
