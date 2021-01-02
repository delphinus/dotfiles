vim.o.timeout = true
vim.o.timeoutlen = 300
vim.o.ttimeoutlen = 10

local vimp = require'vimp'
vimp.bind('nv', '<C-d>', '3<C-d>')
vimp.bind('nv', '<C-u>', '3<C-u>')
vimp.nnoremap('*', '*N')
vimp.nnoremap('_', '<C-w>_')
vimp.nnoremap('<Esc><Esc>', [[<Cmd>nohlsearch<CR>]])
-- https://twitter.com/uvrub/status/1341036672364945408
vimp.inoremap({'silent'}, '<CR>', '<C-g>u<CR>')

local function qf_or_loc(mode)
  return function()
    local is_loc = vim.fn.getloclist(0, {winid = 0}).winid
    local prefix = is_loc and 'l' or 'c'
    local cmd = ':'..prefix..mode
    print(cmd)
    pcall(vim.cmd, cmd)
  end
end

vimp.nnoremap('qn', qf_or_loc('next'))
vimp.nnoremap('qp', qf_or_loc('prev'))
vimp.nnoremap('qq', qf_or_loc('close'))

require'augroups'.set{
  -- quit with `q` when started by `view`
  set_mapping_for_view = {
    {'VimEnter', '*', 'if &readonly | nnoremap q <Cmd>qa<CR> | endif'},
  },

  -- When editing a file, always jump to the last known cursor position. Don't
  -- do it when the position is invalid or when inside an event handler
  -- (happens when dropping a file on gvim).
  jump_to_the_last_position = {
    {'BufReadPost', '*', function()
      local last_pos = vim.fn.line[['"]]
      if last_pos >= 1 and last_pos <= vim.fn.line'$' then
        vim.cmd[[execute 'normal! g`"']]
      end
    end},
  },

  -- The native implementation of vim-higlihghtedyank in NeoVim
  highlighted_yank = {
    {'TextYankPost', '*', vim.highlight.on_yank},
  },
}

