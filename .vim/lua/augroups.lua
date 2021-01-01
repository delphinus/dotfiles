local M = {
  funcs = {},
  name = (function()
    local file = debug.getinfo(1, 'S').source
    return file:match('/(%a+)%.lua$')
  end)()
}

M.set = function(groups)
  assert(type(groups) == 'table', 'group definitions must be a table')
  for name, definitions in pairs(groups) do
    assert(type(name) == 'string', 'augroup name must be a string')
    assert(type(definitions) == 'table', 'definitions must be a table')
    local cmds = {}
    for _, d in ipairs(definitions) do
      local events, patterns, cmd_or_func = d[1], d[2], d[3]
      local command
      if type(cmd_or_func) == 'string' then
        command = cmd_or_func
      else
        table.insert(M.funcs, cmd_or_func)
        command = ([[lua require'%s'.funcs[%d]()]]):format(M.name, #M.funcs)
      end
      table.insert(cmds, 'autocmd '..events..' '..patterns..' '..command)
    end
    vim.cmd('augroup '..name)
    vim.cmd[[autocmd!]]
    for _, cmd in ipairs(cmds) do
      vim.cmd(cmd)
    end
    vim.cmd[[augroup END]]
  end
end

return M
