function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, {...})
  local str = unpack(objects)
  print(str == '' and 'nil' or str)
end

function _G.add_option_string(opt, to_add)
  for c in to_add:gmatch('.') do
    if opt:find(c, 1, true) == nil then
      opt = opt..c
    end
  end
  return opt
end
