local m = function(def)
  def.cmd = {'Telescope'}
  def.module_pattern = {'telescope.*'}
  return def
end

return {
  m{'delphinus/telescope-memo.nvim'},
  m{'kyazdani42/nvim-web-devicons'},
  m{'nvim-lua/popup.nvim'},
  m{'nvim-telescope/telescope-fzf-native.nvim', run = 'make'},
  m{'nvim-telescope/telescope-ghq.nvim'},
  m{'nvim-telescope/telescope-github.nvim'},
  m{'nvim-telescope/telescope-node-modules.nvim'},
  m{'nvim-telescope/telescope-symbols.nvim'},
  m{'nvim-telescope/telescope-z.nvim'},

  m{
    'nvim-telescope/telescope-smart-history.nvim',
    requires = m{'tami5/sql.nvim'},
  },

  m{
    'nvim-telescope/telescope.nvim',
    requires = {
      {'plenary.nvim'},
    },
    after = {
      'nvim-web-devicons',
      'popup.nvim',
      'telescope-fzf-native.nvim',
      'telescope-ghq.nvim',
      'telescope-github.nvim',
      'telescope-memo.nvim',
      'telescope-node-modules.nvim',
      'telescope-smart-history.nvim',
      'telescope-symbols.nvim',
      'telescope-z.nvim',
    },

    setup = function()
      local m = require'mappy'
      local me = 'telescope.nvim'
      local packer = require'packer'
      local plugins = vim.tbl_keys(packer_plugins[me].load_after)

      local loader = function()
        local not_loaded = vim.tbl_filter(function(p)
          return not packer_plugins[p].loaded
        end, plugins)
        if not packer_plugins[me].loaded then
          table.insert(not_loaded, me)
        end
        packer.loader(unpack(not_loaded))
      end

      local builtin = function(name)
        loader()
        return require'telescope.builtin'[name]
      end
      local extensions = function(name)
        loader()
        return require'telescope'.load_extension(name)
      end
      local path_display = function(opts, path)
        local home = '^'..loop.os_homedir()
        local gh_dir = home..'/git/github.com'
        local gh_e_dir = home..'/git/'..vim.g.gh_e_host
        local ghq_dir = home..'/git'
        local packer_dir = home..'/.local/share/nvim/site/pack/packer'
        return path:gsub(gh_dir, '$GH'):gsub(gh_e_dir, '$GH_E'):gsub(ghq_dir, '$GIT'):gsub(packer_dir, '$PACKER'):gsub(home, '~')
      end

      -- Lines
      m.nnoremap('#', function()
        builtin'current_buffer_fuzzy_find'{}
      end)

      -- Files
      m.nnoremap('<Leader>fB', function() builtin'buffers'{} end)
      m.nnoremap('<Leader>fb', function()
        local cwd = fn.expand'%:h'
        builtin'file_browser'{cwd = cwd == '' and nil or cwd}
      end)
      m.nnoremap('<Leader>ff', function()
        -- TODO: stopgap measure
        if loop.cwd() == loop.os_homedir() then
          api.echo({
            {
              'find_files on $HOME is danger. Launch file_browser instead.',
              'WarningMsg',
            },
          }, true, {})
          builtin'file_browser'{}
        -- TODO: use loop.fs_stat ?
        elseif fn.isdirectory(loop.cwd()..'/.git') == 1 then
          builtin'git_files'{}
        else
          builtin'find_files'{hidden = true}
        end
      end)
      m.nnoremap('<Leader>fg', function()
        builtin'grep_string'{
          only_sort_text = true,
          search = fn.input'Grep For ❯ ',
        }
      end)
      m.nnoremap('<Leader>f:', function() builtin'command_history'{} end)
      m.nnoremap('<Leader>fG', function() builtin'grep_string'{} end)
      m.nnoremap('<Leader>fH', function() builtin'help_tags'{lang = 'en'} end)
      m.nnoremap('<Leader>fh', function() builtin'help_tags'{} end)
      m.nnoremap('<Leader>fm', function() builtin'man_pages'{sections = {'ALL'}} end)
      m.nnoremap('<Leader>fn', function() extensions'node_modules'.list{} end)
      m.nnoremap('<Leader>fo', function() builtin'oldfiles'{path_display = path_display} end)
      m.nnoremap('<Leader>fp', function() extensions'projects'.projects{} end)
      m.nnoremap('<Leader>fq', function() extensions'ghq'.list{} end)
      m.nnoremap('<Leader>fr', function() builtin'resume'{} end)
      m.nnoremap('<Leader>fz', function() extensions'z'.list{} end)

      -- Memo
      m.nnoremap('<Leader>mm', function() extensions'memo'.list{} end)
      m.nnoremap('<Leader>mg', function()
        extensions'memo'.grep_string{
          only_sort_text = true,
          search = fn.input'Memo Grep For ❯ ',
        }
      end)

      -- LSP
      m.nnoremap('<Leader>sr', function() builtin'lsp_references'{} end)
      m.nnoremap('<Leader>sd', function() builtin'lsp_document_symbols'{} end)
      m.nnoremap('<Leader>sw', function() builtin'lsp_workspace_symbols'{} end)
      m.nnoremap('<Leader>sc', function() builtin'lsp_code_actions'{} end)

      -- Git
      m.nnoremap('<Leader>gc', function() builtin'git_commits'{} end)
      m.nnoremap('<Leader>gb', function() builtin'git_bcommits'{} end)
      m.nnoremap('<Leader>gr', function() builtin'git_branches'{} end)
      m.nnoremap('<Leader>gs', function() builtin'git_status'{} end)

      -- Copied from telescope.nvim
      m.cnoremap({'silent'}, '<A-r>', [[<C-\>e ]]..
        [["lua require'telescope.builtin'.command_history{]]..
        [[default_text = [=[" . escape(getcmdline(), '"') . "]=]}"<CR><CR>]])
    end,

    config = function()
      local actions = require'telescope.actions'
      local actions_state = require'telescope.actions.state'
      local telescope = require'telescope'
      local from_entry = require'telescope.from_entry'
      local builtin = function(name) return require'telescope.builtin'[name] end
      local extensions = function(name)
        return require'telescope'.load_extension(name)
      end
      local Path = require'plenary.path'

      local run_in_dir = function(prompt_bufnr, f)
        local entry = actions_state.get_selected_entry()
        local dir = from_entry.path(entry)
        if fn.isdirectory(dir) then
          f(dir)
        else
          api.echo(
            {{('This is not a directory: %s'):format(dir), 'WarningMsg'}}, true, {}
          )
        end
      end

      local run_find_files = function(prompt_bufnr)
        run_in_dir(prompt_bufnr, function(dir) builtin'find_files'{cwd = dir} end)
      end

      local run_live_grep = function(prompt_bufnr)
        run_in_dir(prompt_bufnr, function(dir) builtin'live_grep'{cwd = dir} end)
      end

      local preview_scroll = function(direction)
        return function(prompt_bufnr)
          actions.get_current_picker(prompt_bufnr).previewer:scroll_fn(direction)
        end
      end

      telescope.setup{
        defaults = {
          mappings = {
            i = {
              ['<C-a>'] = run_find_files,
              ['<C-c>'] = actions.close,
              ['<C-g>'] = run_live_grep,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-s>'] = actions.select_horizontal,
              ['<C-n>'] = actions.cycle_history_next,
              ['<C-p>'] = actions.cycle_history_prev,
              ['<C-d>'] = preview_scroll(3),
              ['<C-u>'] = preview_scroll(-3),
              ['<C-f>'] = preview_scroll(30),
              ['<C-b>'] = preview_scroll(-30),
              -- https://github.com/nvim-telescope/telescope.nvim/issues/1579
              ['<C-w>'] = function() vim.cmd[[normal! bcw]] end,
            },
            n = {
              ['<C-a>'] = run_find_files,
              ['<C-c>'] = actions.close,
              ['<C-g>'] = run_live_grep,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-s>'] = actions.select_horizontal,
              ['<C-n>'] = actions.select_horizontal,
              ['<C-d>'] = preview_scroll(3),
              ['<C-u>'] = preview_scroll(-3),
            },
          },
          vimgrep_arguments = {
            'pt',
            '--nocolor',
            '--nogroup',
            '--column',
            '--smart-case',
            '--hidden',
          },
          history = {
            path = Path:new(fn.stdpath'data', 'telescope_history.sqlite3').filename,
            limit = 100,
          },
          winblend = 10,
          prompt_prefix = '❯❯❯ ',
          selection_caret = '❯ ',
          dynamic_preview_title = true,
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      }
      -- This is needed to setup telescope-fzf-native. It overrides the sorters
      -- in this.
      extensions'fzf'
      -- This is needed to setup telescope-smart-history.
      extensions'smart_history'
      -- This is needed to setup projects.nvim
      extensions'projects'
    end,
  }
}
