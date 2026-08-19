---@type vim.lsp.Config
return {
  filetypes = { "markdown", "text", "help" },
  settings = {
    ["harper-ls"] = {
      -- Most notes here are Japanese prose with English terms sprinkled in.
      -- Harper otherwise treats the whole buffer as English and flags every
      -- bare Latin token (`ONP`, `L1`, list markers like `B.`) plus the
      -- Japanese punctuation around them. Measured on a typical Obsidian
      -- note: 77 diagnostics without this, 5 with it. Upstream calls the
      -- feature unstable, but it degrades gracefully -- English-only buffers
      -- keep almost every lint they had before.
      isolateEnglish = true,
    },
  },
}
