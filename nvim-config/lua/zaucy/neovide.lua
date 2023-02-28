vim.g.neovide_cursor_animation_length = 0.02
vim.g.neovide_refresh_rate = 144
vim.g.neovide_cursor_vfx_mode = "pixiedust"
vim.g.neovide_transparency = 1.0
vim.g.neovide_scale_factor = 1.0
vim.opt.guifont = { "Fira Code Regular", ":h12" }

vim.cmd [[ autocmd FocusGained,BufEnter,CursorHold * checktime ]]
