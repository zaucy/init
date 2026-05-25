local gh = function(x)
	return "https://github.com/" .. x
end

local cb = function(x)
	return "https://codeberg.org/" .. x
end

local local_overrides = {
	-- multibuffer = vim.fn.expand("~/projects/zaucy/multibuffer.nvim"),
	-- proj = vim.fn.expand("~/projects/zaucy/proj.nvim"),
	-- perforce = vim.fn.expand("~/projects/zaucy/perforce.nvim"),
}

local modules_to_setup = {}

local original_pack_get = vim.pack.get
---@diagnostic disable-next-line: duplicate-set-field
vim.pack.get = function(names)
	local results = original_pack_get(names)
	for _, res in ipairs(results) do
		local name = res.spec.name
		if local_overrides[name] then
			res.path = local_overrides[name]
		end
	end
	return results
end

local function plugin_load(info)
	local plugin_name = info.spec.name
	table.insert(modules_to_setup, plugin_name)
	if local_overrides[plugin_name] then
		local local_path = local_overrides[plugin_name]

		-- Clear existing loaded modules for this plugin to force a reload
		for k, _ in pairs(package.loaded) do
			if k == plugin_name or k:match("^" .. plugin_name .. "%.") then
				package.loaded[k] = nil
			end
		end

		vim.opt.runtimepath:prepend(local_path)
		local after = local_path .. "/after"
		if vim.fn.isdirectory(after) == 1 then
			vim.opt.runtimepath:append(after)
		end

		if vim.loader then
			vim.loader.reset(local_path)
		end
	else
	end
	vim.cmd("packadd! " .. plugin_name)
end

-- stylua: ignore start
vim.pack.add({
	{ name = "oil",                       src = gh("stevearc/oil.nvim")                          },
	{ name = "oil-git-status",            src = gh("refractalize/oil-git-status.nvim")           },
	{ name = "nvim-web-devicons",         src = gh("nvim-tree/nvim-web-devicons")                },
	{ name = "gitsigns",                  src = gh("lewis6991/gitsigns.nvim")                    },
	{ name = "diffview",                  src = gh("sindrets/diffview.nvim")                     },
	{ name = "lspconfig",                 src = gh("neovim/nvim-lspconfig")                      },
	{ name = "mason",                     src = gh("mason-org/mason.nvim")                       },
	{ name = "lazydev",                   src = gh("folke/lazydev.nvim")                         },
	{ name = "luvit-meta",                src = gh("Bilal2453/luvit-meta")                       },
	{ name = "mason-lspconfig",           src = gh("mason-org/mason-lspconfig.nvim")             },
	{ name = "clangd_extensions",         src = gh("p00f/clangd_extensions.nvim")                },
	{ name = "aerial",                    src = gh("stevearc/aerial.nvim")                       },
	{ name = "inc_rename",                src = gh("smjonas/inc-rename.nvim")                    },
	{ name = "render-markdown",           src = gh("MeanderingProgrammer/render-markdown.nvim")  },
	{ name = "multibuffer",               src = gh("zaucy/multibuffer.nvim")                     },
	{ name = "multicursor",               src = gh("jake-stewart/multicursor.nvim")              },
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
	{ name = "blink-cmp",                 src = gh("saghen/blink.cmp") },
	{ name = "blink.lib",                 src = gh("saghen/blink.lib") },
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
}, { load = plugin_load })
-- stylua: ignore end

vim.cmd.colorscheme("catppuccin-nvim")
vim.cmd("highlight ZaucySubstituteSelect guibg=#151521")

for _, plugin_name in ipairs(modules_to_setup) do
	local modname = "zaucy.plugins." .. plugin_name
	local modpath = "lua/" .. modname:gsub("%.", "/") .. ".lua"
	local has_config_file = #vim.api.nvim_get_runtime_file(modpath, false) > 0

	if has_config_file then
		local has_config_mod, config_mod_or_error = pcall(require, modname)
		if not has_config_mod then
			vim.notify(config_mod_or_error, vim.log.levels.ERROR)
		else
			-- NOTE: should I do anything with the config mod?
			_ = config_mod_or_error
		end
	end
end

-- some legacy plugin configs that aren't associated with a particular plugin from my lazy plugin manager days
require("zaucy.plugins.lsp")
require("zaucy.plugins.ui")
require("zaucy.plugins.gamedev")
require("zaucy.plugins.git")
require("zaucy.plugins.chat")
