-- TODO: temporal workaround to un-syntax Error on comments
api.exec([[
  syntax match jsonCommentError "\/\*\(\*\(\/\)\@!\|\_[^*]\)*\*\/"
  highlight! def link jsonCommentError Comment
]], false)
