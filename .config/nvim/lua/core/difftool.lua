local function load_plugin(name)
  local plugin_dir = vim.fn.stdpath "data" .. "/lazy/" .. name
  if not not vim.uv.fs_stat(plugin_dir) then
    vim.opt.rtp:prepend(plugin_dir)
    return true
  end
  return false
end

local function setup()
  if load_plugin "sweetie.nvim" then
    vim.cmd.colorscheme "sweetie"
  end
  vim.keymap.set("n", "J", "]q", { desc = "Next quickfix item", remap = true })
  vim.keymap.set("n", "K", "[q", { desc = "Prev quickfix item", remap = true })
  vim.keymap.set("n", "<C-j>", "<C-w>w", { desc = "Move to next window" })
  vim.keymap.set("n", "<C-k>", "<C-w>w", { desc = "Move to prev window" })
  vim.keymap.set("n", "<C-d>", "3<C-d>", { desc = "Scroll down 3 lines" })
  vim.keymap.set("n", "<C-u>", "3<C-u>", { desc = "Scroll up 3 lines" })
  vim.keymap.set("n", "Q", "<Cmd>:qa!<CR>", { desc = "Quit all" })
  vim.cmd.packadd "nvim.difftool"
  require("difftool").open(unpack(vim.fn.argv() --[[@as string[] ]]))
end

return { setup = setup }
