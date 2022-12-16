vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
	use 'wbthomason/packer.nvim'
	use 'williamboman/mason.nvim'
	use 'williamboman/mason-lspconfig.nvim'
	use 'nvim-treesitter/nvim-treesitter'
	-- use 'neovim/nvim-lspconfig'
	use '~/projects/zaucy/nvim-lspconfig' -- I'm using my fork while I develop Ecsact
	use 'L3MON4D3/LuaSnip'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-nvim-lsp-document-symbol'
	use 'hrsh7th/cmp-nvim-lsp-signature-help'
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/nvim-cmp'
	use 'folke/tokyonight.nvim'
	use 'nvim-lua/plenary.nvim'
	use 'stevearc/dressing.nvim'
	use 'lewis6991/gitsigns.nvim'
	use 'nathom/filetype.nvim'
	use {
		'j-hui/fidget.nvim',
		config = function()
			require("fidget").setup {}
		end,
	}
	use {
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup {}
		end
	}
	use {
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-github.nvim" },
			{ "jvgrootveld/telescope-zoxide" },
		},
	}
	use 'mfussenegger/nvim-dap'
	use 'rcarriga/nvim-dap-ui'
	use {
		'nvim-tree/nvim-tree.lua',
		requires = {
			'nvim-tree/nvim-web-devicons'
		},
		tag = 'nightly'
	}
	use {
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end
	}
	use '~/projects/zaucy/bazel.nvim'
	-- keeping around until vim is more second nature
	use 'ThePrimeagen/vim-be-good'
	use { "akinsho/toggleterm.nvim", tag = '*' }
	use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
	use {
		'EthanJWright/vs-tasks.nvim',
		requires = {
			'nvim-lua/popup.nvim',
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope.nvim',
		},
	}
	use {
		'MunifTanjim/prettier.nvim',
		requires = {
			'neovim/nvim-lspconfig',
			'jose-elias-alvarez/null-ls.nvim',
		},
	}
end)
