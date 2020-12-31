function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, {...})
  print(unpack(objects))
end

-- https://teukka.tech/luanvim.html
function _G.nvim_create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    vim.cmd('augroup '..group_name)
    vim.cmd'autocmd!'
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
      vim.cmd(command)
    end
    vim.cmd'augroup END'
  end
end

function _G.add_option_string(opt, to_add)
  for c in to_add:gmatch('.') do
    if opt:find(c, 1, true) == nil then
      opt = opt..c
    end
  end
  return opt
end
