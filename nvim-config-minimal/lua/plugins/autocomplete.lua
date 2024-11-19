local slow_completion_prefix = {
	'!', -- shell autocomplete is really slow on Windows
	'\'', -- autocompelte on selections just doesn't work very well
	'%',
	'Q', -- I prefix commands I don't type manually with this so that my cmdline autocomplete can be snappy and no flickering occurs
	'te',
	'ter',
	'term',
	'termi',
	'termin',
	'termina',
	'terminal',
	'terminal ',
}

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
		opts = {
			filter_completion = function(input)
				if input == '' then
					return false
				end

				for _, prefix in ipairs(slow_completion_prefix) do
					if vim.startswith(input, prefix) then
						return false
					end
				end
				return true
			end,
		},
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"zaucy/cmp-bazel.nvim",
			{ "https://codeberg.org/FelipeLema/cmp-async-path", lazy = true },
		},
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
				---@diagnostic disable-next-line: missing-fields
				formatting = {
					format = function(_, vim_item)
						---@diagnostic disable-next-line: return-type-mismatch
						if vim_item == nil then return vim_item end
						vim_item.kind = (cmp_kinds[vim_item.kind] or '') .. vim_item.kind
						return vim_item
					end,
				},
				view = {
					entries = {
						name = 'native',
					},
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<Right>'] = cmp.mapping.confirm({ select = true }),
					['<CR>'] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'bazel' },
					{ name = 'async_path' },
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
