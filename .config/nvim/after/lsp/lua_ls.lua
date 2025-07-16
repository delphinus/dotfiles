return {
  settings = {
    Lua = {
      -- https://blog.atusy.net/2025/07/15/prefer-luadoc-to-luals-semantictokens/
      semantic = { enable = false },
      completion = { callSnippet = "Replace" },
      diagnostics = {
        globals = {
          "vim",
          "packer_plugins",
          "api",
          "fn",
          "loop",

          -- for testing
          "after_each",
          "before_each",
          "describe",
          "it",

          -- hammerspoon
          "hs",

          -- wrk
          "wrk",
          "setup",
          "id",
          "init",
          "request",
          "response",
          "done",

          -- vusted
          "after_each",
          "before_each",
          "describe",
          "it",
        },
      },
      format = { enable = false },
      hint = { enable = true, setType = true },
      codeLens = { enable = true },
      runtime = { version = "LuaJIT" },
      telemetry = { enable = false },
    },
  },
}
