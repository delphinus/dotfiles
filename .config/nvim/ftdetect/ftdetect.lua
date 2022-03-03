local function ftdetect(pattern)
  return function(cb)
    if type(cb) == "string" then
      api.create_autocmd({ "BufNewFile", "BufRead" }, { pattern = pattern, command = cb })
    else
      api.create_autocmd({ "BufNewFile", "BufRead" }, { pattern = pattern, callback = cb })
    end
  end
end

ftdetect "*.gs,.amethyst" [[set filetype=javascript]]
ftdetect "*.jbuilder" [[set filetype=ruby]]
ftdetect "*pentadactylrc*,*.penta" [[set filetype=pentadactyl]]
ftdetect "*.tt2" [[setf tt2html]]
ftdetect "*.tt" [[setf tt2html]]
ftdetect ".zpreztorc" [[setf zsh]]
ftdetect "*.plist,*.ttx" [[setf xml]]
ftdetect "*.applescript" [[setf applescript]]
ftdetect "*.pm" [[setf perl]]

ftdetect "*.xt"(function()
  fn["dist#ft#FTperl"]()
end)

-- TODO: filetype.lua does not detect script with shebang.
ftdetect "*"(function()
  local top = api.buf_get_lines(0, 0, 1, false)[1]
  if top then
    if top:match "^#!" then
      local bin = top:match "^.+/([^/ ]+)"
      if bin == "env" then
        bin = top:match "env +([^ ]+)"
      end
      if bin then
        vim.cmd("setfiletype " .. bin)
      end
    end
  end
end)

ftdetect "*.conf"(function()
  if vim.opt.filetype:get() == "tmux" then
    return
  end
  local sep = package.config:sub(1, 1)
  for _, item in ipairs(vim.split(fn.expand "%:p", sep)) do
    if item:match "tmux" then
      vim.cmd [[setfiletype tmux]]
      return
    end
  end
end)
