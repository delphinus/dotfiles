local vimp = require'vimp'
local M
M = {
  applescript = function() vimp.inoremap({'buffer'}, '<A-m>', [[￢<CR>]]) end,

  c = function()
    vim.bo.tabstop = 8
    vim.bo.shiftwidth = 8
    vim.bo.softtabstop = 8
    vim.bo.expandtab = false
  end,

  css = function()
    vim.bo.iskeyword = vim.bo.iskeyword..'-'
  end,

  fish = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,

  floaterm = function()
    vim.wo.winblend = 10
    vim.wo.cursorline = false
    vim.wo.scrolloff = 0
    vim.b.dwm_disabled = 1
  end,

  git = function()
    vim.wo.spell = false
    vim.b.dwm_disabled = true
  end,

  gitcommit = function()
    vim.wo.colorcolumn = '50,72'
    vim.wo.spell = true
  end,

  gitmessengerpopup = function()
    vimp.add_buffer_maps(function()
      vimp.nmap('<C-i>', 'O')
      vimp.rbind({'<A-b>', '<C-o>'}, 'o')
      vimp.rbind({'<C-c>', '<CR>', '<Esc>'}, 'q')
    end)
  end,

  go = function()
    vim.wo.foldmethod = 'syntax'
    if vim.o.background == 'light' then
      vim.cmd[[hi! goSameId term=bold cterm=bold ctermbg=225 guibg=#eeeaec]]
    else
      vim.cmd[[hi! goSameId gui=bold term=bold ctermbg=23 ctermfg=7 guifg=#eee8d5 gui=bold]]
    end
  end,

  godoc = function()
    vim.wo.colorcolumn = ''
    vim.bo.auto_cursorline_disabled = 1
  end,

  go_gohtmltmpl = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,

  help = function()
    vim.wo.list = false
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.b.cursorword = 0
  end,

  html_javascript = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,

  jinja = function()
    if vim.endswith(vim.bo.filetype, '.jinja') then
      vim.cmd[[ALEDisableBuffer]]
      vim.b.ale_fix_on_save = 0
    end
  end,

  json = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.wo.cursorcolumn = false
    vim.wo.foldmethod = 'syntax'
    function _G.json_fold_text()
      local line = vim.fn.getline(vim.v.foldstart)
      local sub = vim.fn.substitute(line, [[\v^\s+([^"]*")?]], '', '')
      local sub = vim.fn.substitute(sub, [[\v("[^"]*)?\s*$]], '', '')
      local level = #vim.v.folddashes
      if level <= 12 then
        level = vim.fn.nr2char(0x2170 + level - 1)..' '
      end
      return ('%s %3d 行: %s '):format(level, vim.v.foldend - vim.v.foldstart + 1, sub)
    end
    vim.cmd[[let g:JsonFoldText = {-> v:lua.json_fold_text()}]]
    vim.cmd[[setlocal foldtext=g:JsonFoldText()]]
  end,

  markdown = function()
    --[[ vimperator say errors for this. why?
    vimp.add_buffer_maps(function()
      vimp.nmap('<A-m>', '<Plug>MarkdownPreview')
      vimp.nmap('<A-M>', '<Plug>StopMarkdownPreview')
    end)
    ]]
    vim.api.nvim_buf_set_keymap(0, 'n', '<A-m>', '<Plug>MarkdownPreview', {})
    vim.api.nvim_buf_set_keymap(0, 'n', '<A-M>', '<Plug>StopMarkdownPreview', {})
  end,

  perl = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4

    function _G.perl_fold_text()
      local re = vim.regex([[\v^\s*subtest\s*(['"])\zs.{-}\ze\1]])
      local start, finish = re:match_line(0, vim.v.foldstart - 1)
      local cases_part = ''
      local test_name = ''
      if start then
        test_name = vim.fn.getline(vim.v.foldstart):sub(start + 1, finish)
        local cases = 0
        for i = vim.v.foldstart, vim.v.foldend - 1 do
          if re:match_line(0, i) then
            cases = cases + 1
          end
        end
        if cases > 0 then
          cases_part = (' (+ %d case%s)'):format(cases, cases > 1 and 's' or '')
        end
      end

      local level = #vim.v.folddashes
      if level <= 12 then
        level = vim.fn.nr2char(0x2170 + level - 1)..' '
      end
      local lines = vim.v.foldend - vim.v.foldstart + 1
      return ('%s %3d 行: %s%s'):format(level, lines, test_name, cases_part)
    end

    vim.cmd[[let g:PerlFoldText = {-> v:lua.perl_fold_text()}]]
    vim.cmd[[setlocal foldtext=g:PerlFoldText()]]
  end,

  php = function() vim.bo.expandtab = true end,

  python = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,

  qf = function()
    vim.b.dwm_disabled = 1
    vim.b.cursorword = 0
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.list = false
    vim.wo.cursorcolumn = false
  end,

  ruby = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2

    require'augroups'.set{
      ruby_syntax = {
        {'Syntax', 'ruby', function()
          if vim.fn.RailsDetect == 0 then
            vim.cmd[[hi def link rubyRailsTestMethod Function]]
            vim.cmd[[syn keyword rubyRailsTestMethod describe context it its specify shared_context shared_examples shared_examples_for shared_context include_examples include_context it_should_behave_like it_behaves_like before after around subject fixtures controller_name helper_name scenario feature background given described_class]]
            vim.cmd[[syn match rubyRailsTestMethod '\<let\>!\=']]
            vim.cmd[[syn keyword rubyRailsTestMethod violated pending expect expect_any_instance_of allow allow_any_instance_of double instance_double mock mock_model stub_model xit]]
            vim.cmd[[syn match rubyRailsTestMethod '\.\@<!\<stub\>!\@!']]
          end
        end},
      },
    }
  end,

  scss = function() vim.bo.iskeyword = vim.bo.iskeyword..',-' end,

  sh = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,

  tagbar = function() vim.b.dwm_disabled = 1 end,

  toml = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.wo.foldmethod = 'marker'
  end,

  undotree = function()
    vim.b.dwm_disabled = 1
    vim.cmd('vertical resize '..vim.g.undotree_SplitWidth)
  end,

  vim = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,

  vue = function()
    vim.bo.iskeyword = vim.bo.iskeyword..',-,$'
  end,

  ----------------------------------------------------------------

  run = function()
    local ft = vim.fn.expand'<sfile>:t:r'
    if ft == '' then
      error'cannot detect filetype from <sfile>'
    elseif M[ft] == nil then
      error('unknown filetype: '..ft..' in ftplugins.lua')
    end
    M[ft]()
  end,
}

return M
