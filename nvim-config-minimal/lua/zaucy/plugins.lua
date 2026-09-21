local gh = function(x)
	return "https://github.com/" .. x
end

local local_proj = function(x)
	return vim.fn.expand("~/projects/" .. x)
end

-- stylua: ignore start
require("zaucy.plugins-override") {
	-- multibuffer = local_proj("zaucy/multibuffer.nvim"),
	-- proj = local_proj("zaucy/proj.nvim"),
	-- perforce = vim.fn.expand("~/projects/zaucy/perforce.nvim"),
	-- uproject = vim.fn.expand("~/projects/zaucy/uproject.nvim"),
	-- bazel = vim.fn.expand("~/projects/bazel.nvim"),
	-- mcos = vim.fn.expand("~/projects/zaucy/mcos.nvim"),
	-- agy = vim.fn.expand("~/projects/zaucy/agy.nvim"),
}

vim.pack.add({
	{ name = "oil",                       src = gh("stevearc/oil.nvim")                          },
	{ name = "oil-git-status",            src = gh("refractalize/oil-git-status.nvim")           },
	{ name = "nvim-web-devicons",         src = gh("nvim-tree/nvim-web-devicons")                },
	{ name = "gitsigns",                  src = gh("lewis6991/gitsigns.nvim")                    },
	-- { name = "diffview",                  src = gh("sindrets/diffview.nvim")                     },
	{ name = "lspconfig",                 src = gh("neovim/nvim-lspconfig")                      },
	{ name = "mason",                     src = gh("mason-org/mason.nvim")                       },
	{ name = "lazydev",                   src = gh("folke/lazydev.nvim")                         },
	{ name = "luvit-meta",                src = gh("Bilal2453/luvit-meta")                       },
	{ name = "mason-lspconfig",           src = gh("mason-org/mason-lspconfig.nvim")             },
	{ name = "clangd_extensions",         src = gh("p00f/clangd_extensions.nvim")                },
	{ name = "aerial",                    src = gh("stevearc/aerial.nvim")                       },
	{ name = "inc_rename",                src = gh("smjonas/inc-rename.nvim")                    },
	-- { name = "render-markdown",           src = gh("MeanderingProgrammer/render-markdown.nvim")  },
	{ name = "multibuffer",               src = gh("zaucy/multibuffer.nvim")                     },
	{ name = "mcos",                      src = gh("zaucy/mcos.nvim")                            },
	{ name = "nerdy",                     src = gh("2kabhishek/nerdy.nvim")                      },
	{ name = "snacks",                    src = gh("folke/snacks.nvim")                          },
	{ name = "fnm",                       src = gh("zaucy/fnm.nvim")                             },
	{ name = "nos",                       src = gh("zaucy/nos.nvim")                             },
	{ name = "notify",                    src = gh("rcarriga/nvim-notify")                       },
	{ name = "opencode",                  src = gh("sudo-tee/opencode.nvim")                     },
	{ name = "overseer",                  src = gh("stevearc/overseer.nvim")                     },
	{ name = "vp4",                       src = gh("ngemily/vim-vp4")                            },
	{ name = "perforce",                  src = gh("zaucy/perforce.nvim")                        },
	{ name = "nui-components",            src = gh("grapp-dev/nui-components.nvim")              },
	{ name = "proj",                      src = gh("zaucy/proj.nvim")                            },
	{ name = "quicker",                   src = gh("stevearc/quicker.nvim")                      },
	{ name = "resession",                 src = gh("stevearc/resession.nvim")                    },
	{ name = "showkeys",                  src = gh("nvzone/showkeys")                            },
	{ name = "which-key",                 src = gh("folke/which-key.nvim")                       },
	-- { name = "command-completion",     src = gh("zaucy/command-completion.nvim")              },
	{ name = "blink-cmp",                 src = gh("saghen/blink.cmp")                           },
	{ name = "blink.lib",                 src = gh("saghen/blink.lib")                           },
	{ name = "bazel",                     src = gh("zaucy/bazel.nvim")                           },
	{ name = "codediff",                  src = gh("esmuellert/codediff.nvim")                   },
	{ name = "nui",                       src = gh("MunifTanjim/nui.nvim")                       },
	{ name = "coerce",                    src = gh("gregorias/coerce.nvim")                      },
	{ name = "nvim-colorizer",            src = gh("norcalli/nvim-colorizer.lua")                },
	{ name = "tokyonight",                src = gh("folke/tokyonight.nvim")                      },
	{ name = "flow",                      src = gh("0xstepit/flow.nvim")                         },
	{ name = "cyberdream",                src = gh("scottmckendry/cyberdream.nvim")              },
	{ name = "catppuccin",                src = gh("catppuccin/nvim")                            },
	{ name = "conform",                   src = gh("stevearc/conform.nvim")                      },
	{ name = "dap",                       src = gh("mfussenegger/nvim-dap")                      },
	{ name = "dapui",                     src = gh("rcarriga/nvim-dap-ui")                       },
	{ name = "nio",                       src = gh("nvim-neotest/nvim-nio")                      },
	{ name = "dap-virtual-text",          src = gh("theHamsta/nvim-dap-virtual-text")            },
	{ name = "dap-go",                    src = gh("leoluz/nvim-dap-go")                         },
	{ name = "ecsact",                    src = gh("ecsact-dev/ecsact.nvim")                     },
	{ name = "flatbuffers",               src = gh("zchee/vim-flatbuffers")                      },
	{ name = "async",                     src = gh("lewis6991/async.nvim")                       },
	{ name = "uproject",                  src = gh("zaucy/uproject.nvim")                        },
	{ name = "plenary",                   src = gh("nvim-lua/plenary.nvim")                      },
	{ name = "fidget",                    src = gh("j-hui/fidget.nvim")                          },
	{ name = "mcp",                       src = gh("zaucy/mcp.nvim")                             },
	{ name = "agy",                       src = gh("zaucy/agy.nvim")                             },
	{ name = "telescope",                 src = gh("nvim-telescope/telescope.nvim")              },
	{ name = "telescope-zoxide",          src = gh("jvgrootveld/telescope-zoxide")               },
	{ name = "todo-comments",             src = gh("folke/todo-comments.nvim")                   },
	{ name = "treesitter",                src = gh("nvim-treesitter/nvim-treesitter")            },
	{ name = "treesitter-textobjects",    src = gh("nvim-treesitter/nvim-treesitter-textobjects")},
	{ name = "treesitter-context",        src = gh("nvim-treesitter/nvim-treesitter-context")    },
	{ name = "dressing",                  src = gh("stevearc/dressing.nvim")                     },
	{ name = "floaterm",                  src = gh("nvzone/floaterm")                            },
	{ name = "volt",                      src = gh("nvzone/volt")                                },
	{ name = "visual-whitespace",         src = gh("mcauley-penney/visual-whitespace.nvim")      },
	{ name = "guh",                       src = gh("justinmk/guh.nvim")                          },
	{ name = "diffs",                     src = gh("barrettruth/diffs.nvim")                     },
	{ name = "hex",                       src = gh("RaafatTurki/hex.nvim")                       },
	{ name = "ansi",                      src = gh("0xferrous/ansi.nvim")                        },
	-- { name = "mini.completion",           src = gh("nvim-mini/mini.completion")                  },
})
-- stylua: ignore end

vim.cmd.colorscheme("catppuccin-nvim")
vim.cmd("highlight ZaucySubstituteSelect guibg=#151521")

vim.pack.zaucy_mod_init()

-- some legacy plugin configs that aren't associated with a particular plugin from my lazy plugin manager days
require("zaucy.plugins.lsp")
require("zaucy.plugins.ui")
require("zaucy.plugins.gamedev")
require("zaucy.plugins.git")
require("zaucy.plugins.chat")
require("zaucy.plugins.multicursor")
