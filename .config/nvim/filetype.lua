vim.filetype.add {
  extension = {
    applescript = "applescript",
    gs = "javascript", -- Amethyst
    jbuilder = "ruby",
    penta = "pentadactyl",
    plist = "xml",
    pm = "perl",
    tt2 = "tt2html",
    tt = "tt2html",
    ttx = "xml",

    conf = function()
      local sep = package.config:sub(1, 1)
      for _, item in ipairs(vim.split(fn.expand "%:p", sep)) do
        if item:match "tmux" then
          return "tmux"
        end
      end
    end,

    -- dist#ft#FTperl()
    xt = function()
      local dirname = fn.expand "%:p:h:t"
      if fn.expand "%:e" == "t" and (dirname == "t" or dirname == "xt") then
        return "perl"
      end
      if fn.getline(1)[1] == "#" and fn.getline(1):match "perl" then
        return "perl"
      end
      local save_cursor = fn.getpos "."
      fn.cursor(1, 1)
      local has_use = fn.search([[^use\s\s*\k]], "c", 30) > 0
      fn.setpos(".", save_cursor)
      if has_use then
        return "perl"
      end
    end,
  },
  filename = {
    [".amethyst"] = "javascript", -- Amethyst
    [".zpreztorc"] = "zsh",
  },
  pattern = {
    ["*pentadactylrc*"] = "pentadactyl",
    ["*"] = function()
      local top = api.buf_get_lines(0, 0, 1, false)[1]
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
