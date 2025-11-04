-- Debug script for telescope treesitter
-- Run this in Neovim after loading: :luafile ~/.config/nvim-dev/telescope-treesitter/debug.lua

print("=== Debug Info ===")

-- Check if telescope is loaded
local ok, telescope = pcall(require, "telescope")
print("1. Telescope loaded:", ok)

-- Check if nvim-treesitter is loaded
local ok2, ts = pcall(require, "nvim-treesitter")
print("2. nvim-treesitter loaded:", ok2)

-- Check current buffer
local bufnr = vim.api.nvim_get_current_buf()
local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
print("3. Current buffer filetype:", filetype)

-- Check language detection
local lang = vim.treesitter.language.get_lang(filetype) or filetype
print("4. Detected language:", lang)

-- Check if parser exists
local has_parser = pcall(vim.treesitter.language.add, lang)
print("5. Parser exists for " .. lang .. ":", has_parser)

-- Try to get parser
local ok3, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
print("6. Get parser success:", ok3)
if ok3 then
  local tree = parser:parse()[1]
  local root = tree:root()
  print("7. Tree root:", root:type(), "range:", root:range())

  -- Check for locals query
  local query = vim.treesitter.query.get(lang, "locals")
  print("8. Locals query exists:", query ~= nil)

  if query then
    print("9. Query captures:")
    local count = 0
    for id, node, metadata in query:iter_captures(root, bufnr) do
      local capture_name = query.captures[id]
      count = count + 1
      if count <= 10 then  -- Show first 10
        print("   -", capture_name, node:type(), vim.treesitter.get_node_text(node, bufnr))
      end
    end
    print("   Total captures:", count)
  end
else
  print("7. Parser error:", parser)
end

-- Try to call the treesitter picker directly
print("\n10. Attempting to call treesitter picker...")
local ok4, err = pcall(function()
  require("telescope.builtin").treesitter()
end)
print("    Result:", ok4)
if not ok4 then
  print("    Error:", err)
end

print("\n=== End Debug ===")
