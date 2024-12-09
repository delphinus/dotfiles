-- https://zenn.dev/kyoh86/articles/693909b1798383
return function()
  ---@return string?
  local function get_buf_help_name()
    if vim.bo.buftype ~= "help" then
      return
    end
    local bufname = vim.api.nvim_buf_get_name(0)
    local docpath_re = vim.fs.joinpath(vim.env.VIMRUNTIME, "doc/")
    local _, finish = bufname:find(docpath_re, 1, true)
    return finish and (bufname:match("(.*)%.[^.]+$", finish + 1))
  end

  ---@param row integer
  ---@return string?
  local function find_closest_tag(row)
    if row < 0 then
      return
    end
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
    local tag = line:match "%*([^%*]+)%*"
    return tag or find_closest_tag(row - 1)
  end

  ---@param help_name string
  ---@param tag? string
  local function generate_neovim_doc_url(help_name, tag)
    return ("https://neovim.io/doc/user/%s.html%s"):format(help_name, tag and "#" .. tag or "")
  end

  local help_name = get_buf_help_name()
  if not help_name then
    vim.notify("This is not a runtime doc file. Skipping.", vim.log.levels.ERROR)
    return
  end

  local win = vim.api.nvim_get_current_win()
  local row = vim.api.nvim_win_get_cursor(win)[1] - 1
  local tag = find_closest_tag(row)
  local doc_url = generate_neovim_doc_url(help_name, tag)
  vim.ui.open(doc_url)
end
