" TODO: temporal workaround to un-syntax Error on comments
syntax match jsonCommentError "\/\*\(\*\(\/\)\@!\|\_[^*]\)*\*\/"
highlight! def link jsonCommentError Comment
