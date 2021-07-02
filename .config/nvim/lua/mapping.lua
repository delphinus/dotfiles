vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10

local m = require'mappy'
m.bind('nv', '<C-d>', '3<C-d>')
m.bind('nv', '<C-u>', '3<C-u>')
m.nnoremap('_', '<C-w>_')
m.nnoremap('<Esc><Esc>', [[<Cmd>nohlsearch<CR>]])
-- https://twitter.com/uvrub/status/1341036672364945408
m.inoremap({'silent'}, '<CR>', '<C-g>u<CR>')

local toggle_quickfix = function()
  local cmd
  local loclist = vim.fn.getloclist(0, {size = 0, winid = 0})
  if loclist.size > 0 then
    cmd = loclist.winid == 0 and ':lopen' or ':lclose'
  else
    local is_opened
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_get_option(buf, 'filetype') == 'qf' then
        is_opened = true
      end
    end
    cmd = is_opened and ':cclose' or ':copen'
  end
  print(cmd)
  vim.cmd(cmd)
end

m.nnoremap('qq', toggle_quickfix)

require'agrp'.set{
  toggle_quickfix_with_enter = {
    {'FileType', 'qf', function()
      require'agrp'.set{
        toggle_qf_once = {
          {'BufWinLeave', '*', {'once'}, toggle_quickfix},
        },
      }
    end},
  },

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
