return {
  "Shougo/denite.nvim",
  requires = {
    { "Jagua/vim-denite-ghq" },
    { "delphinus/my-denite-sources" },
    { "delphinus/vim-denite-node-modules" },
    { "delphinus/vim-denite-output-files" },
    { "delphinus/vim-denite-scriptnames" },
    { "delphinus/vim-denite-window" },
    { "dwm.vim" },

    {
      "delphinus/denite-git",
      branch = "feature/fix-root-detection",
      requires = { "vim-fugitive" },
    },

    {
      "delphinus/vim-ref",
      branch = "feature/denite",
    },

    {
      "liuchengxu/vim-clap",
      run = [[make install]],
    },

    { "nekowasabi/denite-migemo" },
    { "rafi/vim-denite-z" },
  },
  cmd = { "Denite", "DeniteBufferDir", "DeniteCursorWord" },
  setup = function()
    local cursorline = ""

    function _G.denite_save_cursorline()
      local hi = fn.execute [[hi CursorLine]]
      cursorline = fn.matchstr(hi, [[\(guibg=\)\@<=#[a-zA-Z0-9]\+]])
    end

    function _G.denite_change_cursorline()
      if vim.g.colors_name == "nord" then
        vim.cmd [[hi CursorLine guibg=#183203]]
      elseif vim.g.colors_name:find("solarized8", 1, true) then
        if vim.o.background == "dark" then
          vim.cmd [[hi CursorLine guibg=#073742]]
        else
          vim.cmd [[hi CursorLine guibg=#d8ee5b]]
        end
      end
      if cursorline ~= "" then
        nvim_create_augroups {
          restore_cursorline = {
            { "BufLeave", "<buffer>", "hi CursorLine guibg=" .. cursorline },
          },
        }
      end
    end

    function _G.denite_restore_cursorline()
      if cursorline ~= "" then
        vim.cmd("hi CursorLine guibg=" .. cursorline)
      end
    end

    nvim_create_augroups {
      denite_cursorline = {
        { "ColorScheme", "*", [[lua denite_save_cursorline()]] },
        { "BufEnter", [[\[denite\]-*]], [[lua denite_change_cursorline()]] },
        { "BufEnter", "denite-filter", [[lua denite_restore_cursorline()]] },
      },
    }

    local vimp = require "vimp"
    vimp.nnoremap("#", [[<Cmd>Denite line<CR>]])
    vimp.nnoremap("z/", [[<Cmd>DeniteCursorWord grep:.<CR>]])
    vimp.nnoremap("z<C-]>", [[<Cmd>DeniteCursorWord -immediately outline<CR>]])
    vimp.nnoremap("zG", [[<Cmd>execute 'Denite grep:' . expand('%:h') . '::!'<CR>]])
    vimp.nnoremap("zH", [[<Cmd>Denite help<CR>]])
    vimp.nnoremap("ZH", [[<Cmd>DeniteCursorWord help<CR>]])
    vimp.nnoremap("zL", function()
      if vim.bo.filetype == "go" then
        vim.cmd [[Denite decls]]
      else
        fn["denite#util#print_error"] "decls does not support filetypes except go"
      end
    end)
    vimp.nnoremap("zN", [[<Cmd>DeniteProjectDir -expand my_file my_file:new<CR>]])
    vimp.nnoremap("zP", [[<Cmd>Denite node_modules<CR>]])
    vimp.nnoremap("zS", [[<Cmd>Denite scriptnames<CR>]])
    vimp.nnoremap("zT", [[<Cmd>Denite z<CR>]])
    vimp.nnoremap("zU", [[<Cmd>Denite -resume<CR>]])
    vimp.nnoremap("zY", [[<Cmd>Denite -default-action=delete miniyank<CR>]])
    vimp.nnoremap("zZ", [[<Cmd>Denite buffer -input=term:// -immediately<CR>]])
    vimp.nnoremap("za", [[<Cmd>Denite -expand file/rec<CR>]])
    vimp.nnoremap("zd", [[<Cmd>Denite -buffer-name=dwm dwm:no-current:all window:no-current:all<CR>]])
    vimp.nnoremap("ze", [[<Cmd>Denite memo/grep::!<CR>]])
    vimp.nnoremap("zf", [[<Cmd>Denite floaterm floaterm:new -auto-action=preview<CR>]])
    vimp.nnoremap("zgI", [[<Cmd>Denite gitlog:all<CR>]])
    vimp.nnoremap("zgc", [[<Cmd>Denite gitchanged<CR>]])
    vimp.nnoremap("zgf", [[<Cmd>Denite gitfiles<CR>]])
    vimp.nnoremap("zgi", [[<Cmd>Denite gitlog<CR>]])
    vimp.nnoremap("zgs", [[<Cmd>Denite gitstatus<CR>]])
    vimp.nnoremap("zh", [[<Cmd>Denite ghq<CR>]])
    vimp.nnoremap("zi", [[<Cmd>Denite -max-dynamic-update-candidates=0 grep<CR>]])
    vimp.nnoremap("zj", [[<Cmd>Denite -resume -cursor-pos=+1 -immediately<CR>]])
    vimp.nnoremap("zk", [[<Cmd>Denite -resume -cursor-pos=-1 -immediately<CR>]])
    vimp.nnoremap("zl", function()
      if vim.bo.filetype == "go" then
        vim.cmd [[Denite decls:'%:p']]
      else
        vim.cmd [[Denite outline]]
      end
    end)
    vimp.nnoremap("zm", [[<Cmd>Denite memo memo:new<CR>]])
    vimp.nnoremap("zn", [[<Cmd>DeniteBufferDir -expand my_file my_file:new<CR>]])
    vimp.nnoremap("zp", [[<Cmd>Denite -expand buffer file/old<CR>]])
    vimp.nnoremap("zy", [[<Cmd>Denite miniyank<CR>]])
  end,
  config = function()
    for _, name in ipairs {
      "vim-denite-ghq",
      "my-denite-sources",
      "vim-denite-node-modules",
      "vim-denite-output-files",
      "vim-denite-scriptnames",
      "vim-denite-window",
      "dwm.vim",
      "denite-git",
      "vim-ref",
      "vim-clap",
      "denite-migemo",
      "vim-denite-z",
    } do
      vim.cmd("packadd " .. name)
    end

    vim.cmd [[packadd dwm.vim]]

    -- Use pt for grepping files
    fn["denite#custom#var"]("grep", "command", { "pt" })
    fn["denite#custom#var"]("grep", "default_opts", {
      "--nogroup",
      "--nocolor",
      "--smart-case",
      "--ignore=.git",
      "--ignore=dist",
      "--ignore=node_modules",
    })
    fn["denite#custom#var"]("grep", "recursive_opts", {})
    fn["denite#custom#var"]("grep", "pattern_opt", {})
    fn["denite#custom#var"]("grep", "separator", { "--" })
    fn["denite#custom#var"]("grep", "final_opts", {})

    -- Use fish's z for denite-z
    local z_data = vim.env.HOME .. "/.local/share/z/data"
    if fn.filereadable(z_data) then
      fn["denite#custom#var"]("z", "data", z_data)
    end

    -- Use fd for finding files
    local file_rec_cmd
    if fn.executable "fd" then
      file_rec_cmd = { "fd", "--follow", "--hidden", "--exclude", ".git", ".*" }
    else
      file_rec_cmd = { "pt", "--follow", "--nocolor", "--nogroup", "-g=", "" }
    end
    fn["denite#custom#var"]("my_file_rec", "command", file_rec_cmd)
    fn["denite#custom#var"]("file/rec", "command", file_rec_cmd)

    function _G.denite_dwm_new(context)
      local target = context.targets[0]
      if target.action__path then
        for w = 1, fn.winnr "$" do
          local bufnr = fn.winbufnr(w)
          local path = fn.fnamemodify(fn.bufname(bufnr), ":p")
          if path == target.action__path then
            vim.cmd("execute " .. w .. "wincmd w")
            fn.DWM_Focus()
            return
          end
        end
      end
      local action = target.action__command and "execute" or "open"
      fn["denite#do_action"](context, action, context.targets)
    end

    function _G.denite_candidate_grep(context)
      local path = context.targets[0].action__path
      local dir = fn["denite#util#path2directory"](path)
      local sources_queue = context.sources_queue
      sources_queue:insert { name = "file/rec", args = { dir } }
      return { sources_queue = sources_queue }
    end

    function _G.denite_candidate_grep(context)
      local path = context.targets[0].action__path
      local sources_queue = context.sources_queue
      sources_queue:insert { name = "grep", args = { path, "", "!" } }
      return { is_interactive = false, sources_queue = sources_queue }
    end

    function _G.denite_narrow_grep(context)
      local sources = context.sources or {}
      local filtered = vim.tbl_filter(function(source)
        return source.name == "grep"
      end, sources)
      if vim.tbl_isempty(filtered) then
        fn["denite#util#print_error"] "current sources does not include `grep`."
        return
      end
      local args = filtered[0].args or {}
      -- TODO: add feature to know is_interactive in context
      local path = args[0] or ""
      local opt = args[1] or ""
      local input = context.input or ""
      local pattern = input:gsub("%s+", ".*")
      local sources_queue = context.sources_queue
      sources_queue:insert { name = "grep", args = { path, opt, pattern } }
      return { sources_queue = sources_queue }
    end

    vim.cmd [[let g:DeniteDwmNew = {context -> v:lua.denite_dwm_new(context)}]]
    vim.cmd [[let g:DeniteCandidateGrep = {context -> v:lua.denite_candidate_grep(context)}]]
    vim.cmd [[let g:DeniteNarrowGrep = {context -> v:lua.denite_narrow_grep(context)}]]

    vim.cmd [[call denite#custom#action('buffer,directory,file,memo,openable,command,ref,git_object,gitlog,gitstatus', 'dwm_new', g:DeniteDwmNew)]]
    vim.cmd [[call denite#custom#action('buffer,directory,file,openable', 'my_file_rec', g:DeniteCandidateGrep)]]
    vim.cmd [[call denite#custom#action('buffer,directory,file,openable', 'file/rec', g:DeniteCandidateGrep)]]
    vim.cmd [[call denite#custom#action('buffer,directory,file,openable', 'grep', g:DeniteCandidateGrep)]]
    vim.cmd [[call denite#custom#action('file', 'grep', g:DeniteNarrowGrep)]]

    vim.cmd [[unlet g:DeniteDwmNew]]
    vim.cmd [[unlet g:DeniteCandidateGrep]]
    vim.cmd [[unlet g:DeniteNarrowGrep]]

    fn["denite#custom#source"]("file/old", "sorters", { "sorter/oldfiles" })
    fn["denite#custom#source"]("grep", "args", { "", "", "!" })
    fn["denite#custom#source"]("grep,memo", "converters", { "converter/abbr_word" })
    fn["denite#custom#source"]("node_modules", "sorters", {})
    fn["denite#custom#source"]("z", "default_action", "narrow")

    -- TODO: detect vim-clap directory automatically
    fn["denite#custom#filter"]("matcher/clap", "clap_path", fn.stdpath "data" .. "/site/pack/packer/opt/vim-clap")
    fn["denite#custom#source"]("_", "matchers", { "matcher/clap" })

    -- migemo matcher
    fn["denite#custom#filter"]("matcher/migemo", "dict_path", "/usr/local/share/migemo/utf-8/migemo-dict")
    -- TODO: disabled temporarily
    -- call denite#custom#source('line,memo', 'matchers', ['matcher/migemo'])

    fn["denite#custom#option"]("_", {
      cached_filter = true,
      cursor_shape = true,
      cursor_wrap = true,
      floating_preview = true,
      -- ref. https://github.com/arcticicestudio/nord-vim/issues/79
      highlight_filter_background = "DeniteFilter",
      highlight_matched_char = "Directory",
      highlight_matched_range = "PreProc",
      match_highlight = true,
      max_dynamic_update_candidates = 100000,
      prompt = "❯ ",
      split = "floating_relative_cursor",
      vertical_preview = true,
    })

    function _G.denite_detect_size()
      local winheight = 20
      local winrow = vim.o.lines < winheight and 0 or (vim.o.lines - winheight) / 2
      local winwidth = vim.o.columns > 240 and vim.o.columns / 2 or 120
      local wincol = vim.o.columns < winwidth and 0 or (vim.o.columns - winwidth) / 2
      fn["denite#custom#option"]("_", {
        wincol = wincol,
        winheight = winheight,
        winrow = winrow,
        winwidth = winwidth,
      })
    end

    nvim_create_augroups {
      denite_detect_size = {
        { "VimResized", "*", [[lua denite_detect_size()]] },
      },
    }

    denite_detect_size()
  end,
  run = [[:UpdateRemotePlugins]],
}
