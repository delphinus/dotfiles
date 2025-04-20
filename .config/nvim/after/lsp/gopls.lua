return {
  settings = {
    hoverKind = "NoDocumentation",
    deepCompletion = true,
    fuzzyMatching = true,
    completeUnimported = true,
    usePlaceholders = true,
    gopls = {
      semanticTokens = true,
      analyses = { unusedparams = true },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
