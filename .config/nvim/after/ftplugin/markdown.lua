-- TODO: mappings for VV
vim.keymap.set("n", "<A-m>", "<Plug>MarkdownPreview", { buffer = true, remap = true })
vim.keymap.set("n", "<A-M>", "<Plug>StopMarkdownPreview", { buffer = true, remap = true })

vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = [[v:lua.require'delphinus.markdown'.foldexpr()]]
vim.opt_local.foldtext = [[v:lua.require'delphinus.markdown'.foldtext()]]
vim.opt_local.conceallevel = 3
vim.opt_local.concealcursor = "nc"
vim.opt_local.wrap = true

vim.treesitter.start(0, "markdown")
