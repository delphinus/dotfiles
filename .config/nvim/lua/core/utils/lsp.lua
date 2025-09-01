local _, _, api = require("core.utils").globals()

local border = {
  { "⣀", "LspBorderTop" },
  { "⣀", "LspBorderTop" },
  { "⣀", "LspBorderTop" },
  { "⢸", "LspBorderRight" },
  { "⠉", "LspBorderBottom" },
  { "⠉", "LspBorderBottom" },
  { "⠉", "LspBorderBottom" },
  { "⡇", "LspBorderLeft" },
}

local function need_me(client, bufnr)
  if client.name == "null-ls" then
    return vim.bo[bufnr].filetype ~= "octo"
  end
  return true
end

local function need_diagnostics(bufnr)
  local base = api.buf_get_name(bufnr):gsub([[.*/]], "")
  for _, r in ipairs {
    [[%.d%.ts$]],
  } do
    if base:match(r) then
      return false
    end
  end
  return true
end

return {
  border = border,

  ---@param dir string
  ---@return boolean
  is_deno_project = function(dir)
    return vim
      .iter({
        [[/deno]],
        [[/ddc]],
        [[/cmp%-look/]],
        [[/neco%-vim/]],
        [[/git%-vines/]],
        [[/murus/]],
        [[/skkeleton/]],
      })
      :any(function(v)
        return not not dir:match(v)
      end)
  end,

  on_attach = function(client, bufnr)
    if not need_me(client, bufnr) then
      vim.notify("lsp: " .. client.name .. " is not needed", vim.log.levels.DEBUG)
      client.stop()
      return
    end

    if not need_diagnostics(bufnr) then
      vim.diagnostic.enable(false, { bufnr = bufnr })
    end

    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end

    api.buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    do
      local dc = vim.lsp.document_color
      local opts = { style = "󰑊" }
      dc.enable(true, bufnr, opts)
      vim.keymap.set("n", "<Space>C", function()
        dc.enable(not dc.is_enabled(bufnr), bufnr, opts)
      end, { buffer = bufnr })
    end

    vim.keymap.set("n", "<Space>E", function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled { bufnr = 0 }, { bufnr = 0 })
    end, { buffer = bufnr })
    vim.keymap.set("n", "<Space>Q", vim.diagnostic.setloclist, { buffer = bufnr })

    vim.keymap.set("n", "<A-]>", vim.lsp.buf.type_definition, { buffer = bufnr })
    vim.keymap.set("n", "<C-w><A-]>", function()
      vim.cmd.split()
      vim.lsp.buf.type_definition()
    end, { buffer = bufnr })
    if vim.o.filetype ~= "help" then
      vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, { buffer = bufnr })
      vim.keymap.set("n", "<C-w><C-]>", function()
        vim.cmd.split()
        vim.lsp.buf.definition()
      end, { buffer = bufnr })
    end
    vim.keymap.set("n", "g0", vim.lsp.buf.document_symbol, { buffer = bufnr })
    vim.keymap.set("n", "gD", vim.lsp.buf.implementation, { buffer = bufnr })
    vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, { buffer = bufnr })
    vim.keymap.set("n", "gd", vim.lsp.buf.declaration, { buffer = bufnr })
    vim.keymap.set("n", "gli", vim.lsp.buf.incoming_calls, { buffer = bufnr })
    vim.keymap.set("n", "glo", vim.lsp.buf.outgoing_calls, { buffer = bufnr })

    if client.supports_method "textDocument/formatting" then
      vim.keymap.set("n", "g=", vim.lsp.buf.format, { buffer = bufnr })
    end

    if not vim.env.LIGHT then
      if client.supports_method "textDocument/inlayHint" then
        local ih = vim.lsp.inlay_hint
        ih.enable(true, { bufnr = bufnr })
        vim.keymap.set("n", "<Space>i", function()
          ih.enable(not ih.is_enabled { bufnr = 0 }, { bufnr = 0 })
        end)
      end
    end

    vim.lsp.on_type_formatting.enable()
  end,

  -- NOTE: This func is deprecated.
  update_tools = function()
    local notify = vim.schedule_wrap(function(msg, level)
      vim.cmd.redraw()
      vim.notify(msg, level)
    end) --[[@as fun(msg: string, level: integer?): nil]]

    local Job = require "plenary.job"
    local function new_job(cmd, args, ...)
      local j = Job:new {
        command = cmd,
        args = args,
        on_start = function()
          notify("start: " .. cmd, vim.log.levels.DEBUG)
        end,
        on_exit = function(self, code)
          if code == 0 then
            notify("end: " .. cmd, vim.log.levels.DEBUG)
          else
            notify(table.concat(self:stderr_result() or {}, " "), vim.log.levels.WARN)
          end
        end,
        enabled_recording = true,
      }
      local nexts = { j, ... }
      if #nexts > 1 then
        for i = 1, #nexts - 1 do
          nexts[i]:and_then_on_success(nexts[i + 1])
        end
      end
      return j
    end

    local formulae = {
      "ansible-lint",
      "checkmake",
      "coursier",
    }

    local jobs = {
      new_job("brew", { "install", unpack(formulae) }, new_job("brew", { "upgrade", unpack(formulae) })),
      new_job("npm", { "install", "-g", "textlint-rule-preset-ja-spacing" }),
    }

    notify("update_tools: start", vim.log.levels.INFO)
    vim.tbl_map(function(j)
      j:start()
    end, jobs)
    Job.join(unpack(jobs))
    notify("update_tools: end", vim.log.levels.INFO)
  end,
}
