-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function goto_closest_file(filename)
  return function()
    local files = vim.fs.find(filename, {
      upward = true,
      path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    })

    if #files > 0 then
      vim.cmd("e " .. files[1])
    end
  end
end

vim.keymap.set({ "n" }, "gbb", goto_closest_file("BUILD.bazel"), { desc = "Bazel Build File" })
vim.keymap.set({ "n" }, "gbm", goto_closest_file("MODULE.bazel"), { desc = "Bazel Module File" })
vim.keymap.set({ "n" }, "gbw", goto_closest_file("MODULE.bazel"), { desc = "Bazel Workspace File" })
vim.keymap.set({ "n" }, "gbz", goto_closest_file(".bazelrc"), { desc = "Bazelrc File" })
