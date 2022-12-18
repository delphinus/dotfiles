local ok, impatient = pcall(require, "impatient")
if ok then
  impatient.enable_profile()
else
  vim.notify("cannot load impatient", vim.log.levels.WARN)
end

require "core"
