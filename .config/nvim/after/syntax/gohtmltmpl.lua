vim.cmd [[
  syn region gotplAction start="<%" end="%>" contains=@gotplLiteral,gotplControl,gotplFunctions,gotplVariable,goTplIdentifier display
  syn region goTplComment start="<%\(- \)\?/\*" end="\*/\( -\)\?%>" display
]]
