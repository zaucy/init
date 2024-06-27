return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 0
		end,
		opts = {
		},
	},
	{
		"smolck/command-completion.nvim",
		opts = {},
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local cmp = require('cmp')
			local cmp_kinds = {
				Text = '  ',
				Method = '  ',
				Function = '  ',
				Constructor = '  ',
				Field = '  ',
				Variable = '  ',
				Class = '  ',
				Interface = '  ',
				Module = '  ',
				Property = '  ',
				Unit = '  ',
				Value = '  ',
				Enum = '  ',
				Keyword = '  ',
				Snippet = '  ',
				Color = '  ',
				File = '  ',
				Reference = '  ',
				Folder = '  ',
				EnumMember = '  ',
				Constant = '  ',
				Struct = '  ',
				Event = '  ',
				Operator = '  ',
				TypeParameter = '  ',
			}
			cmp.setup({
				formatting = {
					format = function(_, vim_item)
						if vim_item == nil then return vim_item end
						vim_item.kind = (cmp_kinds[vim_item.kind] or '') .. vim_item.kind
						return vim_item
					end,
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<Right>'] = cmp.mapping.confirm({ select = true }),
					['<Tab>'] = cmp.mapping.confirm({ select = true }),
					['<CR>'] = cmp.mapping.confirm({ select = false }),
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
				}),
				experimental = {
					ghost_text = true,
				},
			})
		end
	},
}
