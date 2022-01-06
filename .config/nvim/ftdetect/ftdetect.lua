require("agrp").set {
  my_ftdetect = {
    ["BufNewFile,BufRead"] = {
      { "*.gs,.amethyst", [[set filetype=javascript]] },
      { "*.jbuilder ", [[set filetype=ruby]] },
      { "*pentadactylrc*,*.penta ", [[set filetype=pentadactyl]] },
      {
        "*.xt",
        function()
          fn["dist#ft#FTperl"]()
        end,
      },
      --[[
      {'*', function()
        local top = api.buf_get_lines(0, 0, 1, false)[1]
        if top then
          if top:match'^#!' then
            local bin = top:match'^.+/([^/ ]+)'
            if bin == 'env' then
              bin = top:match'env +([^ ]+)'
            end
            if bin then
              vim.cmd('setfiletype '..bin)
            end
          end
        end
      end},
      ]]
      {
        "*.conf",
        function()
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
        end,
      },
      { "*.tt2 ", [[setf tt2html]] },
      { "*.tt ", [[setf tt2html]] },
      { ".zpreztorc ", [[setf zsh]] },
      { "*.plist,*.ttx ", [[setf xml]] },
      { "*.applescript", [[setf applescript]] },
    },
  },
}
