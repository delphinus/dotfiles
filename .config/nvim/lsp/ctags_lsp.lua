---@type vim.lsp.Config
return {
  cmd = { "ctags-lsp" },
  -- ctags-lsp returns `{ items = vim.NIL }` (JSON null) when there are no
  -- candidates instead of the spec-conformant `{ items = {} }`. blink.cmp's
  -- process_response treats `vim.NIL` as truthy, then `ipairs(vim.NIL)`
  -- errors and bubbles up via async.task.all, discarding LSP responses
  -- from ALL clients (including lua_ls). Normalize the response here so
  -- blink.cmp never sees NIL items from this server.
  on_init = function(client)
    local orig_request = client.request
    client.request = function(self, method, params, handler, ...)
      if method == "textDocument/completion" and handler then
        local original_handler = handler
        handler = function(err, result, ctx, cfg)
          if result and result.items == vim.NIL then
            result.items = {}
          end
          return original_handler(err, result, ctx, cfg)
        end
      end
      return orig_request(self, method, params, handler, ...)
    end
  end,
  -- ctags-lsp does not declare its own filetypes; pick the languages we
  -- actually want tag-based completion in. Markdown is intentionally omitted
  -- (matches the previous cmp-ctags exclusion in nvim-cmp).
  filetypes = {
    "applescript",
    "c",
    "cpp",
    "cs",
    "css",
    "dockerfile",
    "fish",
    "go",
    "html",
    "java",
    "javascript",
    "javascriptreact",
    "json",
    "lua",
    "perl",
    "php",
    "python",
    "ruby",
    "rust",
    "scss",
    "sh",
    "swift",
    "tcl",
    "terraform",
    "typescript",
    "typescriptreact",
    "vim",
    "vue",
    "yaml",
    "zsh",
  },
  root_markers = { ".git", "tags", ".tags" },
}
