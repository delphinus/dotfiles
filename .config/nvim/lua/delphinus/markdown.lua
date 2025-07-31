return {
  foldexpr = function()
    local lines = vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)
    local line = #lines > 0 and lines[1] or ""
    return line:match "^<details" and "a1" or line:match "^</details>" and "s1" or "="
  end,

  foldtext = function()
    -- NOTE: search summary at the top 5 lines
    local head_lines = vim.api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldstart + 4, false)
    local head = table.concat(head_lines, " ")
    local summary = head:match "<summary>(.*)</summary>" or "<details>……</details>"
    return ("+%s %d lines: %s"):format(vim.v.folddashes, vim.v.foldend - vim.v.foldstart, vim.trim(summary))
  end,
}
