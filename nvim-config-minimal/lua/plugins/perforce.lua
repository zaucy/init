local function perforce_opened_all()
	local perforce = require("perforce")
	local n = require("nui-components")

	local r = n.create_renderer({})

	local options = {
		n.separator("Loading..."),
	}

	local function renderer()
		return n.rows(
			n.prompt({
				prefix = "> ",
				placeholder = "search...",
			}),
			n.select({
				data = options,
				multiselect = false,
			})
		)
	end

	r:render(renderer)

	perforce.opened({ all_clients = true }, function(errors, things)
		if errors then
			options = {
				n.separator("ERROR"),
			}
			for _, error in pairs(errors) do
				table.insert(options, n.option(error))
			end
			return
		end

		local user_map = {}

		for _, thing in ipairs(things) do
			local user_items = user_map[thing.user] or {}

			table.insert(options, n.option(thing.depotFile))

			user_map[thing.user] = user_items
		end

		vim.schedule(function()
			r:redraw()
		end)
	end)
end

return {
	{
		"ngemily/vim-vp4",
		keys = {
			{ "<leader>va", "<cmd>Vp4Add<cr>", desc = "Perforce add" },
			{ "<leader>vd", "<cmd>Vp4Delete!<cr>", desc = "Perforce delete" },
			{ "<leader>ve", "<cmd>Vp4Edit<cr>", desc = "Perforce edit" },
			{ "<leader>vr", "<cmd>Vp4Revert!<cr>", desc = "Perforce revert" },
			{ "<leader>vc", "<cmd>Vp4Reopen<cr>", desc = "Perforce change changelist" },
			{ "<leader>vq", "<cmd>Vp4Filelog<cr>", desc = "Perforce file log (quickfix)" },
			{ "<leader>v.", "<cmd>Vp4Diff<cr>", desc = "Perforce file diff" },
		},
	},
	{
		"zaucy/perforce.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"grapp-dev/nui-components.nvim",
		},
		dir = "~/projects/zaucy/perforce.nvim",
		keys = {
			{
				"<leader>vs",
				desc = "Perforce status",
				function()
					local perforce = require("perforce")
					perforce.changelists({}, function(items)
						vim.notify(vim.inspect(items))
					end)
				end,
			},
			{ "<leader>voa", desc = "Perfoce opened (all)", perforce_opened_all },
		},
	},
}
