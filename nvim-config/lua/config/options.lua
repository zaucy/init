-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.terminal_emulator = "nu"
vim.go.shell = "nu"
-- vim.go.showtable = 0
vim.opt.guifont = "FiraCode Nerd Font,Cascadia Code"

vim.g.root_spec = { "cwd" }
vim.opt.colorcolumn = { "80", "120" }
vim.opt.fileformat = "unix"

vim.filetype.add({
  extension = {
    nu = "nu",
  },
})

if vim.g.neovide then
  vim.g.neovide_scroll_animation_length = 0.08
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_animation_length = 0.04
  vim.g.neovide_cursor_trail_size = 0.4

  local default_scale = 1.38
  vim.g.neovide_scale_factor = default_scale

  vim.api.nvim_set_keymap(
    "n",
    "<C-=>",
    ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>",
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<C-->",
    ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>",
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<C-0>",
    ":lua vim.g.neovide_scale_factor = " .. default_scale .. "<CR>",
    { silent = true }
  )
end
