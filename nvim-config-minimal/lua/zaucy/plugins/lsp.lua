vim.lsp.log.set_level("off")
require("mason").setup({})
vim.g.lazydev_enabled = true
require("lazydev").setup({
	library = {
		{ path = "luvit-meta/library" },
	},
})

require("mason-lspconfig").setup({
	automatic_installation = {
		exclude = { "omnisharp" },
	},
	ensure_installed = {
		--- issue with newer lua_ls
		--- https://github.com/folke/lazydev.nvim/issues/136
		"lua_ls@3.16.4",
		"basedpyright",
	},
})

-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- vim.lsp.config("*", {
-- 	capabilities = capabilities,
-- })

vim.lsp.config("basedpyright", {
	-- capabilities = capabilities,
	settings = {
		basedpyright = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
			},
		},
	},
})

vim.lsp.config("clangd", {
	-- capabilities = capabilities,
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=never",
		"--limit-results=100",
		"--j=4",
		"--pch-storage=disk", -- mostly needed for unreal to save on memory
		"--completion-style=bundled",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	root_markers = {
		".clangd",
		"compile_commands.json",
		"build.ninja",
		"CMakeLists.txt",
		".git",
		"Default.uprojectdirs",
	},
})

vim.lsp.config("cppm-lsp", {
	cmd = { "cppm-lsp" },
	filetypes = { "cpp" },
	root_markers = { "build.cppm" },
})

vim.lsp.config("nushell", {
	-- capabilities = capabilities,
	filetypes = { "nu" },
})

vim.lsp.config("ecsact", {
	-- capabilities = capabilities,
	filetypes = { "ecsact" },
})

vim.lsp.enable("nushell", true)
vim.lsp.enable("lua_ls", true)
vim.lsp.enable("basedpyright", true)

require("clangd_extensions").setup({})

require("telescope").load_extension("aerial")
require("aerial").setup({
	layout = {
		default_direction = "left",
		width = nil,
		resize_to_content = true,
	},
	close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },
	autojump = true,
	close_on_select = true,
	highlight_mode = "none",
	highlight_closest = false,
	highlight_on_hover = false,
	highlight_on_jump = false,
	float = {
		border = "rounded",
		relative = "win",
		override = function(conf, _)
			conf.col = 1
			return conf
		end,
	},
})

require("inc_rename").setup({})
