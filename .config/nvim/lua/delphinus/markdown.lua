local line_count = 5
local function target_lines(here)
  return api.buf_get_lines(0, here, here + line_count, false)
end

return {
  foldexpr = function()
    local lines = target_lines(vim.v.lnum - 1)
    local line = #lines > 0 and lines[1] or ""
    return line:match "^<details" and "a1" or line:match "^</details>" and "s1" or "="
  end,

  foldtext = function()
    local text = "<details>……</details>"
    for _, line in ipairs(target_lines(vim.v.foldstart - 1)) do
      local m = line:match "<summary>(.*)</summary>"
      if m then
        text = m
      end
    end
    return ("+%s %d lines: %s"):format(vim.v.folddashes, vim.v.foldend - vim.v.foldstart, text)
  end,
}
