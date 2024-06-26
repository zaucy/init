return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      { "folke/neodev.nvim", opts = {} },
    },
    opts = {
      servers = {
        nushell = {},
        gdscript = {},
        starpls = {},
        omnisharp = { mason = false }, -- using roslyn instead
      },
      inlay_hints = { enabled = false },
    },
  },
  {
    "jmederosalvarado/roslyn.nvim",
    cmds = { "CSInstallRosylyn", "CSTarget" },
    filetypes = { "cs" },
    opts = {
      on_attach = function() end,
      capabilities = nil,
    },
  },
}
