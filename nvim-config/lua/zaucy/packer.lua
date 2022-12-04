vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
	use 'wbthomason/packer.nvim'
	use 'neovim/nvim-lspconfig'
	use 'folke/tokyonight.nvim'
	use 'nvim-lua/plenary.nvim'
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
end)

