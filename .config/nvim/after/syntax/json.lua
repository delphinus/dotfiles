-- TODO: temporal workaround to un-syntax Error on comments
vim.cmd[[
  syntax match jsonCommentError "\/\*\(\*\(\/\)\@!\|\_[^*]\)*\*\/"
  highlight! def link jsonCommentError Comment
]]
