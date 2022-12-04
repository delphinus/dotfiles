-- dist#ft#FTperl()
local ftperl = function(ext)
  return function(path, bufnr)
    local dirname = vim.fs.dirname(path)
    if ext == "t" and (dirname == "t" or dirname == "xt") then
      return "perl"
    end
    local top = api.buf_get_lines(bufnr, 0, 1, false)[1]
    if top == "#" and top:match "perl" then
      return "perl"
    end
    local has_use_regex = vim.regex [[^use\s\s*\k]]
    for line = 0, 29 do
      if has_use_regex:match_line(bufnr, line) then
        return "perl"
      end
    end
  end
end

vim.filetype.add {
  extension = {
    applescript = "applescript",
    gs = "javascript", -- Amethyst
    jbuilder = "ruby",
    penta = "pentadactyl",
    plist = "xml",
    pm = "perl",
    t = ftperl "t",
    tt = "tt2html",
    tt2 = "tt2html",
    ttx = "xml",
    xt = ftperl "xt",

    conf = function(path, bufnr)
      local sep = package.config:sub(1, 1)
      for _, item in ipairs(vim.split(path, sep)) do
        if item:match "tmux" then
          return "tmux"
        end
      end
    end,
  },
  filename = {
    [".amethyst"] = "javascript", -- Amethyst
    [".zpreztorc"] = "zsh",
  },
  pattern = {
    ["*pentadactylrc*"] = "pentadactyl",
    ["*"] = function(path, bufnr, ext)
      local top = api.buf_get_lines(bufnr, 0, 1, false)[1]
      if top then
        if top:match "^#!" then
          local bin = top:match "^.+/([^/ ]+)"
          if bin == "env" then
            bin = top:match "env +([^ ]+)"
          end
          if bin then
            return bin
          end
        end
      end
    end,
  },
}
