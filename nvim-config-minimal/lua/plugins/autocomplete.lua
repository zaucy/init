return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require('which-key').setup({
				preset = "helix",
				delay = 0,
				icons = {
					separator = "",
					keys = {
						Esc = "󱊷",
					},
				},
			})
			require('which-key').add({
				{ "<leader>u", group = "unreal" },
			})
		end,
		keys = {
			{ "<c-s-w>", function()
				require("which-key").show({
					keys = "<c-w>",
					loop = true,
				})
			end },
		},
	},
	{
		"zaucy/command-completion.nvim",
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
					{
						name = "lazydev",
						group_index = 0, -- set group index to 0 to skip loading LuaLS completions
					},
				}),
				experimental = {
					ghost_text = true,
				},
			})
		end
	},
}
