vim.opt_local.colorcolumn = { "50", "72" }
-- guh.nvim reuses the gitcommit filetype for its read-only diff/commit views;
-- skip spellcheck there, else nearly every diff token gets underlined.
vim.opt_local.spell = vim.b.guh == nil
vim.b.dwm_disabled = true
