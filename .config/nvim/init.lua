--vim.g.use_lazy = not not vim.env.LAZY
vim.g.use_lazy = true

if not vim.g.use_lazy then
  local ok, impatient = pcall(require, "impatient")
  if ok then
    impatient.enable_profile()
  else
    vim.notify("cannot load impatient", vim.log.levels.WARN)
  end
end

require "core"
