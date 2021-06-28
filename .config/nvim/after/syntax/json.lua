-- TODO: temporal workaround to un-syntax Error on comments
vim.api.nvim_exec([[
  syntax match jsonCommentError "\/\*\(\*\(\/\)\@!\|\_[^*]\)*\*\/"
  highlight! def link jsonCommentError Comment
]], false)
