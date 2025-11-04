# Telescope Treesitter Minimal Config

This is a minimal configuration for testing the telescope treesitter picker with nvim-treesitter main branch.

## Usage

```bash
# Start Neovim with this minimal config
env NVIM_APPNAME=nvim-dev/telescope-treesitter nvim

# Or create an alias for convenience
alias nvim-test='env NVIM_APPNAME=nvim-dev/telescope-treesitter nvim'
```

## What it does

1. Sets up lazy.nvim package manager in an isolated location
2. Installs required plugins:
   - plenary.nvim
   - nvim-treesitter (main branch by default)
   - telescope.nvim (uses your local modified version)
3. Creates a test Lua file with sample functions
4. Provides a keymap: `<leader>tt` to run `:Telescope treesitter`

## Testing with different branches

The configuration automatically detects which branch API to use based on the availability of `nvim-treesitter.configs` module.

To test with nvim-treesitter **master** branch instead of main:

Edit the init.lua and change:
```lua
branch = "main", -- Change this to "master"
```

The config will automatically:
- Use `nvim-treesitter.configs.setup()` for master branch
- Use `nvim-treesitter.setup()` and `.install()` for main branch

Both branches will work seamlessly without manual configuration changes.

## Expected behavior

When you run `:Telescope treesitter`, you should see a picker listing:
- hello (function)
- goodbye (function)
- M.greet (function)
- M.farewell (function)

## Debugging

If nothing happens:
1. Check for errors: `:messages`
2. Check if treesitter parser is loaded: `:TSInstallInfo`
3. Check if the query exists: `:lua print(vim.inspect(vim.treesitter.query.get("lua", "locals")))`
4. Check the telescope picker manually: `:Telescope`

## Clean up

To remove the test environment:
```bash
# Remove data directory (plugins, cache, etc.)
rm -rf ~/.local/share/nvim-dev/telescope-treesitter

# Remove state directory (logs, shada, etc.)
rm -rf ~/.local/state/nvim-dev/telescope-treesitter

# Remove config directory
rm -rf ~/.config/nvim-dev/telescope-treesitter
```
