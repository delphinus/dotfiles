local fn, uv, api = require("core.utils").globals()

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

local lua_globals = {
  "vim",
  "packer_plugins",
  "api",
  "fn",
  "loop",

  -- for testing
  "after_each",
  "before_each",
  "describe",
  "it",

  -- hammerspoon
  "hs",

  -- wrk
  "wrk",
  "setup",
  "id",
  "init",
  "request",
  "response",
  "done",

  -- vusted
  "after_each",
  "before_each",
  "describe",
  "it",
}

local function is_deno_dir(name)
  return vim
    .iter({
      [[^deno]],
      [[^ddc]],
      [[^cmp%-look$]],
      [[^neco%-vim$]],
      [[^git%-vines$]],
      [[^murus$]],
      [[^skkeleton$]],
    })
    :any(function(v)
      return not not name:match(v)
    end)
end

local function need_me(client, bufnr)
  local Path = require "plenary.path"
  local name = client.name
  if name == "tsserver" or name == "denols" then
    local parent_dir = assert(vim.fs.dirname(api.buf_get_name(bufnr)))
    local deno_found = vim.iter(vim.split(parent_dir, Path.path.sep)):any(is_deno_dir)
    if name == "tsserver" then
      return not deno_found
    end
    return deno_found
  elseif name == "null-ls" then
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

  lua_globals = lua_globals,

  on_attach = function(client, bufnr)
    if not need_me(client, bufnr) then
      vim.notify("lsp: " .. client.name .. " is not needed", vim.log.levels.DEBUG)
      vim.schedule(function()
        vim.lsp.buf_detach_client(bufnr, client.id)
      end)
      return
    end

    if not need_diagnostics(bufnr) then
      vim.diagnostic.disable(bufnr)
    end

    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end

    api.buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    local function goto_next()
      vim.diagnostic.goto_next { popup_opts = { border = border } }
    end

    vim.keymap.set("n", "<A-J>", goto_next, { buffer = bufnr })
    vim.keymap.set("n", "<A-S-Ô>", goto_next, { buffer = bufnr })

    local function goto_prev()
      vim.diagnostic.goto_prev { popup_opts = { border = border } }
    end

    vim.keymap.set("n", "<A-K>", goto_prev, { buffer = bufnr })
    vim.keymap.set("n", "<A-S->", goto_prev, { buffer = bufnr })

    vim.keymap.set("n", "<Space>E", function()
      if vim.b.lsp_diagnostics_disabled then
        vim.diagnostic.enable()
      else
        vim.diagnostic.disable()
      end
      vim.b.lsp_diagnostics_disabled = not vim.b.lsp_diagnostics_disabled
    end, { buffer = bufnr })
    vim.keymap.set("n", "<Space>e", function()
      vim.diagnostic.open_float { border = border }
    end, { buffer = bufnr })
    vim.keymap.set("n", "<Space>q", vim.diagnostic.setloclist, { buffer = bufnr })

    vim.keymap.set("n", "<A-]>", vim.lsp.buf.type_definition, { buffer = bufnr })
    vim.keymap.set("n", "<C-w><A-]>", function()
      vim.cmd.split()
      vim.lsp.buf.type_definition()
    end, { buffer = bufnr })
    if vim.opt.filetype:get() ~= "help" then
      vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, { buffer = bufnr })
      vim.keymap.set("n", "<C-w><C-]>", function()
        vim.cmd.split()
        vim.lsp.buf.definition()
      end, { buffer = bufnr })
    end
    vim.keymap.set("n", "<C-x><C-k>", vim.lsp.buf.signature_help, { buffer = bufnr })
    vim.keymap.set("n", "g0", vim.lsp.buf.document_symbol, { buffer = bufnr })
    vim.keymap.set("n", "gA", vim.lsp.buf.code_action, { buffer = bufnr })
    vim.keymap.set("n", "gD", vim.lsp.buf.implementation, { buffer = bufnr })
    vim.keymap.set("n", "gR", vim.lsp.buf.rename, { buffer = bufnr })
    vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, { buffer = bufnr })
    vim.keymap.set("n", "gd", vim.lsp.buf.declaration, { buffer = bufnr })
    vim.keymap.set("n", "gli", vim.lsp.buf.incoming_calls, { buffer = bufnr })
    vim.keymap.set("n", "glo", vim.lsp.buf.outgoing_calls, { buffer = bufnr })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })

    if client.supports_method "textDocument/formatting" then
      local ignore_paths = {
        "%/neovim$",
        "%/vim$",
        "%/vim%/src$",
      }
      local auto_fmt = require "auto_fmt"
      auto_fmt.on(bufnr, {
        filter = function(c)
          local root_dir = c.config.root_dir
          if root_dir then
            for _, re in ipairs(ignore_paths) do
              local m = root_dir:match(re)
              if m then
                vim.notify("[auto_formatting] this project ignored: " .. m, vim.log.levels.DEBUG)
                return false
              end
            end
          end
          return c.name ~= "tsserver" or c.name ~= "lua"
        end,
      })
      vim.keymap.set("n", "g!", auto_fmt.toggle, { buffer = bufnr })
      vim.keymap.set("n", "g=", vim.lsp.buf.format, { buffer = bufnr })
    end

    if not vim.env.LIGHT then
      if client.supports_method "textDocument/inlayHint" then
        if vim.api.nvim_buf_line_count(bufnr) < 1000 then
          vim.lsp.inlay_hint.enable(bufnr, true)
        else
          vim.notify "inlayHint has been disabled because this file has over 1000 lines"
        end
      end
    end
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
            notify(self:stderr_result(), vim.log.levels.WARN)
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
