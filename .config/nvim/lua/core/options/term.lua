local fn, uv, api = require("core.utils").globals()

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
    ["<C-j>"] = { "<A-j>", "<A-∆>" },
    ["<C-k>"] = { "<A-k>", "<A-˚>" },
    ["<C-q>"] = { "<A-q>", "<A-œ>" },
    ["<C-s>"] = { "<A-s>", "<A-ß>" },
    [":"] = { "<A-;>", "<A-…>" },
  })
  :each(function(map, keys)
    vim.iter(keys):each(function(key)
      vim.keymap.set("t", key, [[<C-\><C-n>]] .. map, { remap = true })
      vim.keymap.set("n", key, map, { remap = true })
    end)
  end)

vim.keymap.set("t", "<A-o>", [[<C-\><C-n><C-w>oi]], { remap = true })
vim.keymap.set("t", "<A-ø>", [[<C-\><C-n><C-w>oi]], { remap = true })
vim.keymap.set("n", "<A-o>", [[<C-w>o]], { remap = true })
vim.keymap.set("n", "<A-ø>", [[<C-w>o]], { remap = true })
vim.keymap.set("t", "<A-CR>", [[<C-\><C-n><A-CR>]], { remap = true })

local function get_register()
  return [[<C-\><C-n>]] .. fn.nr2char(fn.getchar()) .. "pi"
end

vim.keymap.set("t", "<A-r>", get_register, { expr = true, desc = "Get registers" })
vim.keymap.set("t", "<A-®>", get_register, { expr = true, desc = "Get registers" })
