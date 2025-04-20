return {
  settings = {
    Lua = {
      completion = { callSnippet = "Replace" },
      diagnostics = { globals = require("core.utils.lsp").lua_globals },
      format = { enable = false },
      hint = { enable = true, setType = true },
      codeLens = { enable = true },
      runtime = { version = "LuaJIT" },
      telemetry = { enable = false },
    },
  },
}
