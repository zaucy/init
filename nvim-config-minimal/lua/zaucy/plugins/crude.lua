local crude = require("crude")
local p4_crude = require("perforce.plugins.crude")

crude.register_provider("crude-fs", crude.providers["crude-fs"])
crude.register_provider("crude-git", crude.providers["crude-git"])
crude.register_extension("crude-fs-git", crude.extensions.git({}))
crude.register_extension("crude-fs-icons", crude.extensions.icons({}))

crude.register_provider("perforce", p4_crude.provider)
crude.register_extension("crude-fs-p4", p4_crude.fs_signs)

vim.keymap.set("n", "<leader>gs", function()
	local cwd = vim.fn.getcwd()
	vim.cmd.edit("crude-git://" .. cwd .. "//status")
end, { desc = "View Status" })

vim.keymap.set("n", "<leader>gw", function()
	local cwd = vim.fn.getcwd()
	vim.cmd.edit("crude-git://" .. cwd .. "//worktrees")
end, { desc = "View Worktrees" })

vim.keymap.set("n", "<leader>go", function()
	local cwd = vim.fn.getcwd()
	vim.cmd.edit("crude-git://" .. cwd .. "//remotes")
end, { desc = "View Remotes" })

vim.keymap.set("n", "<leader>gb", function()
	local cwd = vim.fn.getcwd()
	vim.cmd.edit("crude-git://" .. cwd .. "//branches")
end, { desc = "View Branches" })

vim.keymap.set("n", "<leader>gt", function()
	local cwd = vim.fn.getcwd()
	vim.cmd.edit("crude-git://" .. cwd .. "//tags")
end, { desc = "View Tags" })

vim.keymap.set("n", "<leader>gl", function()
	local cwd = vim.fn.getcwd()
	vim.cmd.edit("crude-git://" .. cwd .. "//log")
end, { desc = "Git Log" })

vim.keymap.set("n", "<leader>vp", "<cmd>edit p4://<cr>", { desc = "Perforce pending changelists" })
vim.keymap.set("n", "<leader>vs", "<cmd>edit p4://default<cr>", { desc = "Perforce default changelist" })
vim.keymap.set("n", "<leader>voa", "<cmd>edit p4://opened<cr>", { desc = "Perforce opened changelists" })
vim.keymap.set("n", "<leader>vh", "<cmd>edit p4://history<cr>", { desc = "Perforce history" })

crude.setup({
	keymaps = {
		["crude-fs"] = {
			["~"] = function(bufnr)
				local fs = require("crude.providers.fs")
				local dir = vim.b[bufnr].crude_dir or fs.get_dir(bufnr)
				vim.cmd.tcd(dir)
			end,
		},
	},
})
