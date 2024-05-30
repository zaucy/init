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

local telescope_previewer_maker = function(filepath, bufnr, opts)
  local previewers = require("telescope.previewers")
  local no_preview_filepath_suffix = {
    ".png",
    ".jpg",
    ".jpeg",
    ".webp",
    ".webm",
    ".mp4",
    ".avi",
    ".dll",
    ".exe",
    ".pdb",
    ".pdf",
    ".unity",
  }

  for _, suffix in ipairs(no_preview_filepath_suffix) do
    if vim.endswith(filepath, suffix) then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
      return
    end
  end

  previewers.buffer_previewer_maker(filepath, bufnr, opts)
end

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
    -- opts = {
    --   registries = {
    --     "file:~/projects/mason-org/mason-registry",
    --   },
    -- },
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
      opts.defaults.buffer_previewer_maker = telescope_previewer_maker
    end,
    keys = {
      { "<leader>?", "<cmd>Telescope keymaps theme=ivy<cr>", desc = "Keymaps" },
      { "<leader>'", "<cmd>Telescope resume<cr>", desc = "Open last picker" },
    },
  },
  {
    "jvgrootveld/telescope-zoxide",
    keys = {
      { "<leader>z", "<cmd>Telescope zoxide list<cr>" },
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release; cmake --build build --config Release; cmake --install build --prefix build",
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
      defaults = {
        gb = { name = "+bazel" },
      },
    },
  },
  {
    "smjonas/inc-rename.nvim",
    opts = {},
  },
  {
    "stevearc/stickybuf.nvim",
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {},
  },
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    init = function()
      require("telescope").load_extension("aerial")
    end,
    opts = {},
    cmds = {
      "AerialGo",
      "AerialInfo",
      "AerialNext",
      "AerialPrev",
      "AerialOpen",
    },
    keys = {
      { "<leader>s", "<cmd>Telescope aerial sorting_strategy=descending<cr>", desc = "Goto Symbol" },
    },
  },
  {
    "levouh/tint.nvim",
    opts = {},
  },
}
