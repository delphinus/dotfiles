local m = require'mappy'

-- echo syntax highlight information on the cursor
-- http://cohama.hateblo.jp/entry/2013/08/11/020849
local function get_syn(transparent)
  local synid = fn.synID(fn.line'.', fn.col'.', 1)
  if transparent then
    synid = fn.synIDtrans(synid)
  end
  return {
    name = fn.synIDattr(synid, 'name'),
    ctermfg = fn.synIDattr(synid, 'fg', 'cterm'),
    ctermbg = fn.synIDattr(synid, 'bg', 'cterm'),
    guifg = fn.synIDattr(synid, 'fg', 'gui'),
    guibg = fn.synIDattr(synid, 'bg', 'gui'),
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
  if fn.exists'*synstack' then
    local stacks = fn.synstack(fn.line'.', fn.col'.')
    local attrs = fn.tbl_map(function(stack)
      return fn.synIDattr(stack, 'name')
    end, stacks)
    vim.inspect(attrs)
  end
end

-- clean up result of `--startuptime`
function _G.CleanUpStartUpTime()
  -- TODO: use Lua
  vim.env.PACKER = fn.stdpath'data'..'/site/pack/packer'
  vim.cmd('silent! %s,'..fn.expand'$VIMRUNTIME'..',$VIMRUNTIME,')
  vim.cmd('silent! %s,'..fn.resolve(fn.expand'$VIMRUNTIME')..',$VIMRUNTIME,')
  vim.cmd('silent! %s,'..fn.expand'$VIM'..',$VIM,')
  vim.cmd('silent! %s,'..fn.resolve(fn.expand'$VIM')..',$VIM,')
  vim.cmd('silent! %s,'..vim.env.PACKER..',$PACKER,')
  vim.cmd('silent! %s,'..loop.os_homedir()..[[,\~,]])
end

-- echo a string for map definitions from an input key
function _G.GetChar()
  -- TODO: does not redraw??
  vim.cmd[[redraw]]
  print'Press any key:'
  local c = fn.getchar()
  while c == [[\<CursorHold]] do
    vim.cmd[[redraw]]
    print'Press any key:'
    c = fn.getchar()
  end
  vim.cmd[[redraw]]
  print(([[Raw: '%s' | Char: '%s']]):format(c, fn.nr2char(c)))
end
