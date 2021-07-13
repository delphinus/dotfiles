require'agrp'.set{
  my_ftdetect = {
    ['BufNewFile,BufRead'] = {
      {'*.gs,.amethyst', [[set filetype=javascript]]},
      {'*.jbuilder ', [[set filetype=ruby]]},
      {'*/nginx* ', [[set filetype=nginx]]},
      {'*.m ', [[setf objc]]},
      {'*.h ', [[setf objc]]},
      {'*pentadactylrc*,*.penta ', [[set filetype=pentadactyl]]},
      {'*.t', [[call delphinus#perl#test_filetype()]]},
      {'*.xt', [[call delphinus#perl#test_filetype()]]},
      {'*', function()
        local top = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
        if top:match'^#!' then
          local bin = top:match'^.+/([^/ ]+)'
          if bin == 'env' then
            bin = top:match'env +([^ ]+)'
          end
          if bin then
            vim.cmd('setfiletype '..bin)
          end
        elseif top:match'startuml' then
          vim.cmd[[setfiletype plantuml]]
        end
      end},
      {'*.psgi ', [[set filetype=perl]]},
      {'*.pu,*.uml,*.plantuml ', [[setfiletype plantuml]]},
      {'*.conf', function()
        if vim.opt.filetype:get() == 'tmux' then return end
        local sep = package.config:sub(1, 1)
        for _, item in ipairs(vim.split(vim.fn.expand'%:p', sep)) do
          if item == '.tmux' or item == 'tmux' then
            vim.cmd[[setfiletype tmux]]
            return
          end
        end
      end},
      {'*.tt2 ', [[setf tt2html]]},
      {'*.tt ', [[setf tt2html]]},
      {'.zpreztorc ', [[setf zsh]]},
      {'*.plist,*.ttx ', [[setf xml]]},
      {'*.applescript', [[setf applescript]]},
      {'*.cc', [[setf cpp]]},
      {'*.cpp', [[setf cpp]]},
      {'*.cxx,*.c++,*.hh,*.hxx,*.hpp,*.ipp,*.moc,*.tcc,*.inl', [[setf cpp]]},
      {'*.h', [[call dist#ft#FTheader()]]},
      {'*.ts', [[setf typescript]]},
      {'*.tsx', [[setf typescriptreact]]},
    },
  },
}
