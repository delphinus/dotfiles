-- Direct Kitty Graphics Protocol test (no image.nvim dependency)
-- Usage: NVIM_APPNAME=nvim-dev/image-nvim nvim -l ~/.config/nvim-dev/image-nvim/kitty_test.lua
--   or from Neovim:  :luafile ~/.config/nvim-dev/image-nvim/kitty_test.lua

local png_path = vim.fn.expand("~/.config/nvim-dev/image-nvim/sample.png")

-- Read and base64-encode the PNG
local f = io.open(png_path, "rb")
if not f then
  print("Cannot open " .. png_path)
  return
end
local data = f:read("*a")
f:close()

local b64 = vim.base64.encode(data)

-- Kitty Graphics Protocol:
--   \x1b_G<key>=<value>,...;<base64 payload>\x1b\\
--
-- We send the image in chunks (max 4096 bytes per chunk).
-- First chunk:  a=T (transmit+display), f=100 (PNG), t=d (direct data),
--               c=40 (columns), r=15 (rows), m=1 (more chunks follow)
-- Middle chunks: m=1
-- Last chunk:    m=0

local chunk_size = 4096
local chunks = {}
for i = 1, #b64, chunk_size do
  table.insert(chunks, b64:sub(i, i + chunk_size - 1))
end

local out = io.stdout

-- Move cursor down a couple lines to leave space for the header text
print("--- Kitty Graphics Protocol direct test ---")
print("")

for i, chunk in ipairs(chunks) do
  local more = (i < #chunks) and 1 or 0
  if i == 1 then
    -- First chunk: full header
    out:write(string.format(
      "\x1b_Ga=T,f=100,t=d,c=40,r=15,m=%d;%s\x1b\\",
      more, chunk
    ))
  else
    -- Continuation chunk
    out:write(string.format(
      "\x1b_Gm=%d;%s\x1b\\",
      more, chunk
    ))
  end
end
out:flush()

print("")
print("--- Image should appear above this line ---")
