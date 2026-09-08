---@type vim.lsp.Config
return {
  settings = {
    -- NOTE: for Neovim clients, emmylua_ls pulls the `Lua` section first and
    -- the `emmylua` section second, and the last non-empty answer wins.
    -- lazydev.nvim only injects its dynamic library list into `Lua`, so all
    -- settings have to live there, and the `emmylua` defaults that
    -- nvim-lspconfig ships have to be blanked out. The server drops null
    -- answers, so vim.NIL makes that section look unset.
    emmylua = vim.NIL,
    Lua = {
      -- https://blog.atusy.net/2025/07/15/prefer-luadoc-to-luals-semantictokens/
      semanticTokens = { enable = false },
      completion = { callSnippet = true },
      diagnostics = {
        globals = {
          "vim",
          "packer_plugins",
          "api",
          "fn",
          "loop",

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
      -- emmylua_ls has no switch to turn formatting off, so hand it over to
      -- stylua. ALE still fixes on save (see lazies/start.lua); this only
      -- decides what an explicit vim.lsp.buf.format() does.
      format = {
        externalTool = { program = "stylua", args = { "-", "--stdin-filepath", "${file}" } },
      },
      hint = { enable = true },
      codeLens = { enable = true },
      runtime = { version = "LuaJIT" },
    },
  },
}
