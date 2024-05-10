return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      popup_border_style = "rounded",
      use_popups_for_input = false,
      window = {
        position = "float",
      },
    },
    cmds = {
      "Neotree",
    },
    keys = {
      {
        "<leader>e",
        function()
          local current_file = vim.api.nvim_buf_get_name(0)
          if current_file == nil then
            vim.notify("No file", vim.log.levels.ERROR)
            return
          end
          require("neo-tree.command").execute({
            reveal = true,
            reveal_file = current_file,
            reveal_force_cwd = true,
            dir = vim.fs.dirname(current_file),
          })
        end,
        desc = "Explore @ file",
      },
      {
        "<leader>E",
        function()
          require("neo-tree.command").execute({
            reveal = true,
            dir = vim.loop.cwd(),
          })
        end,
        desc = "Explore @ cd",
      },
    },
  },
}
