local M = {}

M.tmux = function()
  if vim.bo.filetype == 'tmux' then return end
  local sep = package.config:sub(1, 1)
  for _, item in ipairs(vim.split(vim.fn.expand'%', sep)) do
    if item == '.tmux' or item == 'tmux' then
      vim.cmd[[setfiletype tmux]]
      return
    end
  end
end

return M
