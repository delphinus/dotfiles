local fn, uv, api = require("core.utils").globals()

vim.o.shell = vim.fn.executable "fish" == 1 and "fish" or vim.o.shell

local group = api.create_augroup("terminal_command", {})
local function terminal_autocmd(event)
  return function(cb)
    local opts = { group = group, pattern = "term://*" }
    if type(cb) == "string" then
      opts.command = cb
      opts.desc = cb
    else
      opts.callback = cb.callback
    end
    api.create_autocmd(event, opts)
  end
end

terminal_autocmd "TermOpen" {
  callback = function()
    vim.opt.scrolloff = 0
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.opt.cursorline = false
    vim.opt.signcolumn = "no"
    vim.cmd.startinsert()
  end,
  desc = "Set default options for terminals",
}
terminal_autocmd "WinEnter" [[startinsert]]
terminal_autocmd "WinEnter" [[doautocmd <nomodeline> FocusGained %]]
terminal_autocmd "WinLeave" [[doautocmd <nomodeline> FocusLost %]]

vim
  .iter({
    { map = "<C-j>", key = "<A-j>" },
    { map = "<C-k>", key = "<A-k>" },
    { map = "<C-q>", key = "<A-q>" },
    { map = "<C-s>", key = "<A-s>" },
    { map = ":", key = "<A-;>" },
  })
  :each(function(v)
    vim.keymap.set("t", v.key, [[<C-\><C-n>]] .. v.map, { remap = true })
    vim.keymap.set("n", v.key, v.map, { remap = true })
  end)

vim.keymap.set("t", "<A-o>", [[<C-\><C-n><C-w>oi]], { remap = true })
vim.keymap.set("n", "<A-o>", [[<C-w>o]], { remap = true })
vim.keymap.set("t", "<A-CR>", [[<C-\><C-n><A-CR>]], { remap = true })
vim.keymap.set("t", "<A-->", [[<C-\><C-n><C-w>_i]], { remap = true })

vim.keymap.set("t", "<A-r>", function()
  return [[<C-\><C-n>]] .. fn.nr2char(fn.getchar()) .. "pi"
end, { expr = true, desc = "Get a register" })
