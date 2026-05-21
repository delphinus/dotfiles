local fn, uv, api = require("core.utils").globals()

vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10

vim.keymap.set("n", "<C-j>", "<C-w>w")
vim.keymap.set("n", "<C-k>", "<C-w>W")
vim.keymap.set("n", "<C-c>", "<Cmd>q<CR>")

vim.keymap.set({ "n", "v" }, "<C-d>", "3<C-d>")
vim.keymap.set({ "n", "v" }, "<C-u>", "3<C-u>")
vim.keymap.set("n", "_", "<C-w>_")

vim.keymap.set("n", "ZA", "<Cmd>qa<CR>")

-- https://twitter.com/uvrub/status/1341036672364945408
vim.keymap.set("i", "<CR>", "<C-g>u<CR>", { silent = true })

vim.keymap.set("n", "ZE", "<Cmd>restart<CR>")
vim.keymap.set("n", "ZR", "<Cmd>restart lua require('persistence').load { last = true }<CR>")

local function silent(cmd)
  vim.cmd("silent " .. cmd)
end

local function when_not_qf(f)
  return function()
    if vim.opt.buftype == "quickfix" then
      vim.notify "already in quickfix window"
    else
      f()
    end
  end
end

vim.keymap.set("n", "qq", function()
  local qflist = fn.getqflist { size = 0, winid = 0 }
  silent "lclose"
  if qflist.size > 0 then
    silent(qflist.winid == 0 and "copen" or "cclose")
  else
    silent "cclose"
  end
end, { desc = "Open/Close quickfix window" })

vim.keymap.set(
  "n",
  "QQ",
  when_not_qf(function()
    local loclist = fn.getloclist(0, { size = 0, winid = 0 })
    silent "cclose"
    if loclist.size > 0 then
      silent(loclist.winid == 0 and "lopen" or "lclose")
    else
      silent "lclose"
    end
  end),
  { desc = "Open/Close location-list window" }
)

vim.keymap.set("n", "qc", function()
  vim.notify "clear quickfix list"
  fn.setqflist {}
end, { desc = "Clear quickfix window" })

vim.keymap.set(
  "n",
  "QC",
  when_not_qf(function()
    vim.notify "clear location list"
    fn.setloclist(0, {})
  end),
  { desc = "Clear location-list window" }
)

api.create_autocmd("VimEnter", {
  desc = "Quit with `q` when started by `view`",
  group = api.create_augroup("set_mapping_for_view", {}),
  command = [[if &readonly | nnoremap q <Cmd>qa<CR> | endif]],
})

-- https://blog.pulkitgangwar.com/neovim-configuration-from-scratch-to-lsp
-- Move the selected region up or down
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<M-c>", function()
  local filepath = vim.fn.expand "%:p"
  if filepath == "" then
    vim.notify("No file to preview", vim.log.levels.WARN)
    return
  end
  local width = math.min(math.floor(vim.o.columns * 0.8), 100)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen({ "mcat", "-pt", "kanagawa", filepath }, {
    on_exit = function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })
  vim.cmd.startinsert()
end)

-- Open macOS Dictionary for the word under cursor or selected text
local function lookup_dictionary()
  local buf = vim.api.nvim_get_current_buf()

  ---@pram c vim.lsp.Client
  local can_hover = vim.iter(vim.lsp.get_clients { bufnr = buf }):any(function(c)
    return c:supports_method "textDocument/hover"
  end)
  if can_hover then
    vim.lsp.buf.hover()
    return
  end

  local word
  local mode = api.get_mode().mode

  if mode == "v" or mode == "V" or mode == "\22" then
    -- Visual mode: get selected text
    vim.cmd 'normal! "vy'
    word = vim.fn.getreg "v"
  else
    -- Normal mode: get word under cursor
    word = vim.fn.expand "<cword>"
  end

  if word ~= "" then
    vim.system { "open", "dict://" .. word }
  end
end

-- Set K mapping only if not already mapped
api.create_autocmd({ "FileType", "BufWinEnter" }, {
  desc = "Set K to look up word in macOS Dictionary if not already mapped",
  group = api.create_augroup("macos_dictionary_mapping", {}),
  callback = function()
    local buf = api.get_current_buf()
    -- Check if K is already mapped in normal or visual mode
    if fn.mapcheck("K", "n") == "" then
      vim.keymap.set("n", "K", lookup_dictionary, { buffer = buf, desc = "Look up word in macOS Dictionary" })
    end
    if fn.mapcheck("K", "v") == "" then
      vim.keymap.set("v", "K", lookup_dictionary, { buffer = buf, desc = "Look up word in macOS Dictionary" })
    end
  end,
})

-- In lazy.nvim spec files: tag `"user/repo"` strings with an extmark carrying
-- both a URL highlight and an `url` field. gx picks the URL up via
-- `vim.ui._get_urls()` (which reads extmark URLs), and the TUI emits OSC 8
-- hyperlinks so terminals (iTerm2 / WezTerm Cmd+Click etc.) handle the click.
local plugin_ns = vim.api.nvim_create_namespace "lazy_spec_plugin"
local plugin_pat = [[^["']([%w._-]+/[%w._-]+)["']$]]

local function highlight_plugin_names(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "lua")
  if not ok or not parser then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, plugin_ns, 0, -1)
  local tree = parser:parse()[1]
  if not tree then
    return
  end
  local query = vim.treesitter.query.parse("lua", "(string) @str")
  for _, node in query:iter_captures(tree:root(), buf) do
    local repo = vim.treesitter.get_node_text(node, buf):match(plugin_pat)
    if repo then
      local sr, sc, er, ec = node:range()
      vim.api.nvim_buf_set_extmark(buf, plugin_ns, sr, sc, {
        end_row = er,
        end_col = ec,
        hl_group = "@string.special.url",
        url = "https://github.com/" .. repo,
      })
    end
  end
end

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  desc = "Highlight `user/repo` as a clickable GitHub link in lazy.nvim spec files",
  group = vim.api.nvim_create_augroup("lazy_spec_link", {}),
  pattern = {
    "*/.config/nvim/lua/lazies/*.lua",
    "*/.config/nvim-dev/*/init.lua",
  },
  callback = function(args)
    highlight_plugin_names(args.buf)
    vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
      buffer = args.buf,
      callback = function()
        highlight_plugin_names(args.buf)
      end,
    })
  end,
})

-- Dedent yank: yank then strip the common leading indent from the target
-- register so the result pastes flush against the left margin. Useful for
-- copying a function/`{}` block out of a deeply nested context. Honors a
-- register prefix like `"*\yaf` so the dedented text lands in the clipboard.
-- For charwise selections that start mid-line (e.g. `@function.outer` capturing
-- `function() ... end` out of `callback = function() ... end`), the first line
-- in the register loses its leading whitespace because the selection began at
-- a column past it. Compensate by treating the first line's effective indent
-- as start_col + (its own remaining leading ws); strip accordingly.
local function dedent_register(regname, start_col)
  regname = (regname ~= nil and regname ~= "") and regname or '"'
  start_col = start_col or 0
  local info = vim.fn.getreginfo(regname)
  local lines = info.regcontents
  if not lines or #lines == 0 then
    return
  end
  local min = vim.iter(lines):enumerate():fold(math.huge, function(acc, i, l)
    if not l:match "%S" then
      return acc
    end
    return math.min(acc, #(l:match "^%s*") + (i == 1 and start_col or 0))
  end)
  if min == math.huge or min == 0 then
    return
  end
  lines = vim.iter(lines)
    :enumerate()
    :map(function(i, l)
      local strip = i == 1 and math.max(0, min - start_col) or min
      return l:sub(strip + 1)
    end)
    :totable()
  vim.fn.setreg(regname, lines, info.regtype)
end

-- v:register is set when <Leader>y is pressed but may be reset by the time
-- the operator callback fires after the motion completes, so stash it here.
local pending_reg

---@param motion "line"|"char"|"block"
function _G._dedent_yank_op(motion)
  local r = (pending_reg ~= nil and pending_reg ~= "") and pending_reg or '"'
  pending_reg = nil
  local prefix = r == '"' and "" or ('"' .. r)
  local cmd = motion == "line" and ("'[V']" .. prefix .. "y") or ("`[v`]" .. prefix .. "y")
  vim.cmd("normal! " .. cmd)
  local start_col = 0
  if motion == "char" then
    local _, col = unpack(vim.api.nvim_buf_get_mark(0, "["))
    start_col = col
  end
  dedent_register(r, start_col)
end

vim.keymap.set("n", "<Leader>y", function()
  pending_reg = vim.v.register
  vim.o.operatorfunc = "v:lua._dedent_yank_op"
  return "g@"
end, { expr = true, desc = "Yank (dedented)" })

vim.keymap.set("n", "<Leader>Y", function()
  pending_reg = vim.v.register
  vim.o.operatorfunc = "v:lua._dedent_yank_op"
  return "g@_"
end, { expr = true, desc = "Yank line (dedented)" })

vim.keymap.set("x", "<Leader>y", function()
  local r = (vim.v.register ~= "" and vim.v.register) or '"'
  local prefix = r == '"' and "" or ('"' .. r)
  local was_charwise = vim.fn.mode() == "v"
  vim.cmd("normal! gv" .. prefix .. "y")
  local start_col = 0
  if was_charwise then
    local _, col = unpack(vim.api.nvim_buf_get_mark(0, "["))
    start_col = col
  end
  dedent_register(r, start_col)
end, { desc = "Yank (dedented)" })
