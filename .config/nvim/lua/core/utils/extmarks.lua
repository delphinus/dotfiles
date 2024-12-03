---@alias core.utils.extmarks.Type "highlight"|"sign"|"virt_text"|"virt_lines"

---@class core.utils.extmarks.Result
---@field ns_id integer
---@field ns_name string
---@field type core.utils.extmarks.Type

---@type table<integer, string>
local ns_cache = {}

---@param bufnr integer
---@param row integer
---@param ext_type? core.utils.extmarks.Type
---@return table
local function get_extmarks_info(bufnr, row, ext_type)
  local extmarks = vim.api.nvim_buf_get_extmarks(
    bufnr,
    -1,
    { row, 0 },
    { row + 1, 0 },
    { details = true, type = ext_type }
  )
  local all_ns
  return vim.iter(extmarks):fold({}, function(a, b)
    local id, details = b[1], b[4]
    if not ns_cache[details.ns_id] then
      if not all_ns then
        all_ns = vim.iter(vim.api.nvim_get_namespaces()):fold({}, function(all, k, v)
          all[v] = k
          return all
        end)
      end
      ns_cache[details.ns_id] = all_ns[details.ns_id]
    end
    details.id = id
    details.ns_name = ns_cache[details.ns_id]
    details.type = details.sign_text and "sign"
      or details.hl_group and "highlight"
      or details.virt_text and "virt_text"
      or "virt_lines"
    table.insert(a, details)
    return a
  end)
end

---@class core.utils.extmarks.InspectOpts
---@field bufnr? integer
---@field row? integer
---@field col? integer
---@field type? core.utils.extmarks.Type

return {
  ---@param opts core.utils.extmarks.InspectOpts
  inspect = function(opts)
    local bufnr = opts.bufnr or 0
    local row = opts.row
    if not row then
      local win = bufnr == 0 and vim.api.nvim_get_current_win() or vim.fn.bufwinid(bufnr)
      if win == -1 then
        error "row is required for buffers not visible in a window"
      end
      row = vim.api.nvim_win_get_cursor(win)[1] - 1
    end
    bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr

    local info = get_extmarks_info(bufnr, row, opts.type)
    table.sort(info, function(a, b)
      return a.ns_name < b.ns_name
        or (a.ns_name == b.ns_name and a.type < b.type)
        or (a.ns_name == b.ns_name and a.type == b.type and a.id < b.id)
    end)

    local function make_add(lines)
      return function(chunks)
        for i, chunk in ipairs(chunks) do
          if i > 1 then
            table.insert(lines, { " " })
          end
          table.insert(lines, type(chunk) == "table" and chunk or { chunk })
        end
        table.insert(lines, { "\n" })
        return lines
      end
    end

    local msg = vim.iter(info):fold({}, function(a, i)
      local add = make_add(a)
      if i.type == "sign" then
        return add {
          { i.ns_name, "Title" },
          { i.type, "Type" },
          { ('"%s" %s'):format(i.sign_text, i.sign_hl_group), i.sign_hl_group },
        }
      elseif i.type == "virt_text" then
        return add(vim.iter(i.virt_text):fold({ { i.ns_name, "Title" }, { i.type, "Type" } }, function(chunks, b)
          if b[2] then
            table.insert(chunks, { ('"%s" %s'):format(b[1], b[2]), b[2] })
          else
            table.insert(chunks, { ('"%s"'):format(b[1]) })
          end
          return chunks
        end))
      elseif i.type == "highlight" then
        return add {
          { i.ns_name, "Title" },
          { i.type, "Type" },
          { i.hl_group, i.hl_group },
        }
      end
      return a
    end)
    vim.api.nvim_echo(msg, true, {})
  end,
}
