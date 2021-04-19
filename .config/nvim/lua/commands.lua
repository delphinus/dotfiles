local m = require'mappy'

-- echo syntax highlight information on the cursor
-- http://cohama.hateblo.jp/entry/2013/08/11/020849
local function get_syn(transparent)
  local synid = vim.fn.synID(vim.fn.line'.', vim.fn.col'.', 1)
  if transparent then
    synid = vim.fn.synIDtrans(synid)
  end
  return {
    name = vim.fn.synIDattr(synid, 'name'),
    ctermfg = vim.fn.synIDattr(synid, 'fg', 'cterm'),
    ctermbg = vim.fn.synIDattr(synid, 'bg', 'cterm'),
    guifg = vim.fn.synIDattr(synid, 'fg', 'gui'),
    guibg = vim.fn.synIDattr(synid, 'bg', 'gui'),
  }
end

local function syn_string(syn)
  local values = vim.tbl_map(
    function(key) return key..': '..syn[key] end,
    {'name', 'ctermfg', 'ctermbg', 'guifg', 'guibg'}
  )
  return table.concat(values, ' ')
end

function _G.SyntaxInfo()
  print(syn_string(get_syn()))
  print'linked_to'
  print(syn_string(get_syn(true)))
end

-- https://github.com/arcticicestudio/nord-vim/issues/242#issuecomment-761756223
function _G.SynStack()
  if vim.fn.exists'*synstack' then
    local stacks = vim.fn.synstack(vim.fn.line'.', vim.fn.col'.')
    local attrs = vim.fn.tbl_map(function(stack)
      return vim.fn.synIDattr(stack, 'name')
    end, stacks)
    vim.inspect(attrs)
  end
end

-- clean up result of `--startuptime`
function _G.CleanUpStartUpTime()
  -- TODO: use Lua
  vim.env.PACKER = vim.fn.stdpath'data'..'/site/pack/packer'
  vim.cmd('silent! %s,'..vim.fn.expand'$VIMRUNTIME'..',$VIMRUNTIME,')
  vim.cmd('silent! %s,'..vim.fn.resolve(vim.fn.expand'$VIMRUNTIME')..',$VIMRUNTIME,')
  vim.cmd('silent! %s,'..vim.fn.expand'$VIM'..',$VIM,')
  vim.cmd('silent! %s,'..vim.fn.resolve(vim.fn.expand'$VIM')..',$VIM,')
  vim.cmd('silent! %s,'..vim.env.PACKER..',$PACKER,')
  vim.cmd('silent! %s,'..vim.loop.os_homedir()..[[,\~,]])
end

-- echo a string for map definitions from an input key
function _G.GetChar()
  -- TODO: does not redraw??
  vim.cmd[[redraw]]
  print'Press any key:'
  local c = vim.fn.getchar()
  while c == [[\<CursorHold]] do
    vim.cmd[[redraw]]
    print'Press any key:'
    c = vim.fn.getchar()
  end
  vim.cmd[[redraw]]
  print(([[Raw: '%s' | Char: '%s']]):format(c, vim.fn.nr2char(c)))
end
