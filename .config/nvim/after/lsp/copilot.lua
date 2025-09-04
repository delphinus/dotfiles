-- https://zenn.dev/vim_jp/articles/a6839f7204a611

return {
  on_init = function()
    local hlc = vim.api.nvim_get_hl(0, { name = "Comment" })
    vim.api.nvim_set_hl(0, "ComplHint", vim.tbl_extend("force", hlc, { underline = true }))
    local hlm = vim.api.nvim_get_hl(0, { name = "MoreMsg" })
    vim.api.nvim_set_hl(0, "ComplHintMore", vim.tbl_extend("force", hlm, { underline = true }))

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local bufnr = args.buf

        vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

        vim.keymap.set("i", "<A-e>", function()
          vim.lsp.inline_completion.get()
          if vim.fn.pumvisible() == 1 then
            return "<A-e>"
          end
        end, { silent = true, expr = true, buffer = bufnr })

        vim.keymap.set("i", "<A-f>", function()
          vim.lsp.inline_completion.select()
        end, { silent = true, buffer = bufnr })
        vim.keymap.set("i", "<A-b>", function()
          vim.lsp.inline_completion.select { count = -1 * vim.v.count1 }
        end, { silent = true, buffer = bufnr })
      end,
    })
  end,
}
