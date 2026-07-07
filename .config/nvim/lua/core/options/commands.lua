local fn, uv, api = require("core.utils").globals()

-- http://cohama.hateblo.jp/entry/2013/08/11/020849
local function get_syn(transparent)
  local synid = fn.synID(fn.line ".", fn.col ".", 1)
  if transparent then
    synid = fn.synIDtrans(synid)
  end
  return {
    name = fn.synIDattr(synid, "name"),
    ctermfg = fn.synIDattr(synid, "fg", "cterm"),
    ctermbg = fn.synIDattr(synid, "bg", "cterm"),
    guifg = fn.synIDattr(synid, "fg", "gui"),
    guibg = fn.synIDattr(synid, "bg", "gui"),
  }
end

local function syn_string(syn)
  local values = vim.tbl_map(function(key)
    return key .. ": " .. syn[key]
  end, { "name", "ctermfg", "ctermbg", "guifg", "guibg" })
  return table.concat(values, " ")
end

api.create_user_command("SyntaxInfo", function()
  print(syn_string(get_syn()))
  print "linked_to"
  print(syn_string(get_syn(true)))
end, { desc = "Show syntax highlight information on the cursor" })

-- https://github.com/arcticicestudio/nord-vim/issues/242#issuecomment-761756223
api.create_user_command("SynStack", function()
  if fn.exists "*synstack" then
    local stacks = fn.synstack(fn.line ".", fn.col ".")
    local attrs = vim.tbl_map(function(stack)
      return fn.synIDattr(stack, "name")
    end, stacks)
    print(vim.inspect(attrs))
  end
end, { desc = "Show syntax highlight stack" })

api.create_user_command("CleanUpStartUpTime", function()
  -- TODO: use Lua
  vim.env.PACKER = fn.stdpath "data" .. "/site/pack/packer"
  local funcs = vim
    .iter({
      { before = fn.expand "$VIMRUNTIME", after = "$VIMRUNTIME" },
      { before = fn.resolve(fn.expand "$VIMRUNTIME"), after = "$VIMRUNTIME" },
      { before = fn.expand "$VIM", after = "$VIM" },
      { before = fn.resolve(fn.expand "$VIM"), after = "$VIM" },
      { before = vim.env.PACKER, after = "$PACKER" },
      { before = uv.os_homedir(), after = [[\~]] },
    })
    :map(function(v)
      return ("silent! %%s,%s,%s"):format(v.before, v.after)
    end)
    :totable()
  vim.cmd(table.concat(funcs, "\n"))
  vim.cmd "g/sourcing nvim_exec2() called/d"
end, { desc = "Clean up --startuptime result" })

-- echo the map-ready name of an input key (e.g. <C-CR>, <Esc>)
api.create_user_command("GetChar", function()
  print "Press any key:"
  local s = fn.getcharstr()
  -- print in the next loop so the message survives the post-getchar redraw
  -- (getchar 直後の print は再描画で消えることがあるため schedule で出す)
  vim.schedule(function()
    vim.cmd.redraw()
    -- keytrans() gives the mapping-ready name. strtrans() keeps the byte view
    -- printable: raw K_SPECIAL/control bytes (e.g. <C-CR> = <80><fc>^D^M) would
    -- otherwise crash the message UI. NOTE: getchar()/getcharstr() fold <kEnter>
    -- into <CR>; only the mapping engine tells them apart, so test keypad keys
    -- with an actual :inoremap.
    print(([[Key: '%s' | bytes: %s]]):format(fn.keytrans(s), fn.strtrans(s)))
  end)
end, { desc = "Echo the map-ready name of an input key" })

api.create_user_command("Dump", function(opts)
  local obj = assert(load("return " .. opts.args))()
  local function to_str()
    local mt = type(obj) == "table" and getmetatable(obj) or nil
    if mt and mt.__tostring then
      return tostring(obj)
    end
    local options = opts.bang and { newline = " ", indent = "" } or {}
    return vim.inspect(obj, options)
  end

  print(to_str())
end, {
  bang = true,
  desc = "Dump Lua expression",
  nargs = "+",
})

vim.cmd.nnoremenu [[PopUp.Toggle\ Diagnostic <Cmd>lua vim.diagnostic[vim.diagnostic.is_disabled(0) and "enable" or "disable"]()<CR>]]
vim.cmd.nnoremenu [[PopUp.Toggle\ Auto\ Formatting <Cmd>lua require("auto_fmt").toggle()<CR>]]

vim.cmd.cabbrev("IN", "Inspect")

vim.api.nvim_create_user_command("LazySemver", function(opts)
  if #opts.fargs ~= 2 then
    vim.notify("needs 2 args: spec and version", vim.log.levels.ERROR)
    return
  end
  local sv = require "lazy.manage.semver"
  local matched = sv.range(opts.fargs[1]):matches(opts.fargs[2])
  vim.notify(matched and "OK" or "NG", vim.log.levels[matched and "info" or "WARN"])
end, { nargs = "*" })

vim.api.nvim_create_user_command("ShowLSPSettings", function()
  vim.notify(vim.inspect(vim.lsp.get_clients()))
end, { desc = "Show LSP settings" })

vim.api.nvim_create_user_command("ReloadLSPSettings", function()
  vim.lsp.stop_client(vim.lsp.get_clients(), true)
  vim.cmd.edit()
end, { desc = "Reload LSP settings" })
