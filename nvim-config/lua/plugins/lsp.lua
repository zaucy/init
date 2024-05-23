return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nushell = {},
        gdscript = {},
        starpls = {},
      },
      inlay_hints = { enabled = false },
    },
  },
}
