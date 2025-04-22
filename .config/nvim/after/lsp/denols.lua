return {
  init_options = {
    lint = true,
    unstable = true,
  },
  deno = {
    inlayHints = {
      parameterNames = { enabled = "all" },
      parameterTypes = { enabled = true },
      variableTypes = { enabled = true },
      propertyDeclarationTypes = { enabled = true },
      functionLikeReturnTypes = { enabled = true },
      enumMemberValues = { enabled = true },
    },
  },
  root_dir = function(bufnr, cb)
    local bufname = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
    local dir = vim.fs.dirname(bufname)
    local deno_found = vim.fs.find({ "deno.json", "deno.jsonc", "deps.ts" }, { upward = true, path = dir })
    if #deno_found > 0 then
      return cb(vim.fs.dirname(deno_found[1]))
    end
    local git_found = vim.fs.find(".git", { upward = true, path = dir })
    if #git_found > 0 then
      local repo = vim.fs.dirname(git_found[1])
      if require("core.utils.lsp").is_deno_project(repo) then
        return cb(repo)
      end
    end
  end,
}
