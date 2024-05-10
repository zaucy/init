local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
---@diagnostic disable-next-line: inject-field
parser_config.nu = {
  install_info = {
    url = "git@github.com:nushell/tree-sitter-nu.git",
    files = { "src/parser.c" },
    branch = "main",
    requires_generate_from_grammar = false,
  },
}

return {
  {
    "ecsact-dev/ecsact.nvim",
    dir = "~/projects/ecsact-dev/ecsact.nvim",
    lazy = false,
  },
  {
    "j-hui/fidget.nvim",
    opts = {
      notification = {
        window = {
          border = "rounded",
          winblend = 50,
          x_padding = 0,
          y_padding = 0,
        },
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = not vim.g.neovide,
    },
  },
  {
    "zaucy/bazel.nvim",
    dev = true,
    opts = {},
    cmd = { "BazelBuild", "BazelRun", "BazelTest", "BazelDebugLaunch", "BazelSourceTargetRun" },
    keys = {
      { "gbl", "<cmd>BazelGotoLabel<cr>", desc = "Goto Bazel Label" },
      { "gbs", "<cmd>BazelGotoSourceTarget<cr>", desc = "Goto Bazel Source Target" },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      registries = {
        "file:~/projects/mason-org/mason-registry",
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen" },
    opts = {},
    keys = {
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Current File History" },
    },
  },
  {
    "smolck/command-completion.nvim",
    opts = {},
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      render = "compact",
    },
  },
  {
    "folke/twilight.nvim",
    opts = {
      treesitter = true,
    },
  },
  {
    "folke/zen-mode.nvim",
    dependencies = {
      "folke/twilight.nvim",
    },
    opts = {
      window = {
        width = 0.85,
        height = 0.95,
        backdrop = 0.90,

        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          cursorcolumn = false,
          foldcolumn = "0",
          list = false,
        },
      },
      plugins = {
        twilight = { enabled = false },
      },
    },
    keys = {
      {
        "<C-w><cr>",
        function()
          require("zen-mode").toggle()
        end,
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.pickers = {
        builtins = { theme = "ivy" },
        live_grep = { theme = "ivy" },
        vim_options = { theme = "ivy" },
        colorscheme = { theme = "ivy" },
        find_files = { theme = "ivy" },
        git_files = { theme = "ivy" },
        git_stash = { theme = "ivy" },
        git_status = { theme = "ivy" },
        git_commits = { theme = "ivy" },
        git_bcommits = { theme = "ivy" },
        git_branches = { theme = "ivy" },
        git_bcommits_range = { theme = "ivy" },
        buffers = { theme = "ivy" },
        lsp_references = { theme = "ivy" },
        lsp_definitions = { theme = "ivy" },
        lsp_incoming_calls = { theme = "ivy" },
        lsp_outgoing_calls = { theme = "ivy" },
        lsp_implementations = { theme = "ivy" },
        lsp_document_symbols = { theme = "ivy" },
        lsp_type_definitions = { theme = "ivy" },
        lsp_workspace_symbols = { theme = "ivy" },
        lsp_dynamic_workspace_symbols = { theme = "ivy" },
      }
    end,
    keys = {
      { "<leader>?", "<cmd>Telescope keymaps theme=ivy<cr>", desc = "Keymaps" },
      { "<leader>'", "<cmd>Telescope resume<cr>", desc = "Open last picker" },
    },
  },
  {
    "jvgrootveld/telescope-zoxide",
    keys = {
      { "<leader>z", "<cmd>Telescope zoxide list theme=ivy<cr>" },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 0
    end,
    opts = {
      layout = {},
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    },
    init = function()
      local cmp = require("cmp")
      cmp.setup.filetype("harpoon", {
        sources = cmp.config.sources({ name = "path" }, { name = "buffer" }),
      })
    end,
    keys = {
      {
        "<leader>a",
        function()
          require("harpoon"):list():add()
        end,
      },
      {
        "<C-e>",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
      },
      {
        "<C-[>",
        function()
          require("harpoon"):list():prev()
        end,
      },
      {
        "<C-]>",
        function()
          require("harpoon"):list():prev()
        end,
      },
    },
  },
}