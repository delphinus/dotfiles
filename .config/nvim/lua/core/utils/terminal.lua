---@class core.utils.terminal
local M = {}

M.progress_start = function()
  vim.api.nvim_ui_send "\027]9;4;1;0\027\\"
end

M.progress_end = function()
  vim.api.nvim_ui_send "\027]9;4;0\027\\"
end

---@param percent? number
M.progress_set = function(percent)
  vim.api.nvim_ui_send(("\027]9;4;1;%d\027\\"):format(percent or 0))
end

return M
