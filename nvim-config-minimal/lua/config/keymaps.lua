local function goto_closest_file(filename)
	return function()
		local files = vim.fs.find(filename, {
			upward = true,
			path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
		})

		if #files > 0 then
			vim.cmd("e " .. files[1])
		end
	end
end

vim.keymap.set({ "n" }, "gbb", goto_closest_file("BUILD.bazel"), { desc = "Bazel Build File" })
vim.keymap.set({ "n" }, "gbm", goto_closest_file("MODULE.bazel"), { desc = "Bazel Module File" })
vim.keymap.set({ "n" }, "gbw", goto_closest_file("WORKSPACE.bazel"), { desc = "Bazel Workspace File" })
vim.keymap.set({ "n" }, "gbz", goto_closest_file(".bazelrc"), { desc = "Bazelrc File" })

vim.keymap.set({ "n" }, "<C-_>", "<cmd>terminal<cr>", { desc = "Open Terminal" })
vim.keymap.set({ "n" }, "<C-/>", "<cmd>terminal<cr>", { desc = "Open Terminal" })
vim.keymap.set({ "t" }, "<esc><esc>", "<C-\\><C-n>", { desc = "Enter Normal Mode" })
vim.keymap.set({ "t" }, "<C-w>", "<C-\\><C-n><cmd>WhichKey <C-w><cr>", {})
vim.keymap.set({ "t" }, "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
vim.keymap.set({ "t" }, "<C-_>", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- move lines
vim.keymap.set({ "n" }, "<a-j>", "<cmd>m .+1<cr>==", { desc = "move down" })
vim.keymap.set({ "n" }, "<a-k>", "<cmd>m .-2<cr>==", { desc = "move up" })
vim.keymap.set({ "i" }, "<a-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "move down" })
vim.keymap.set({ "i" }, "<a-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "move up" })
vim.keymap.set({ "v" }, "<a-j>", ":m '>+1<cr>gv=gv", { desc = "move down" })
vim.keymap.set({ "v" }, "<a-k>", ":m '<-2<cr>gv=gv", { desc = "move up" })

vim.keymap.set({ "n" }, "<a-down>", "<cmd>m .+1<cr>==", { desc = "move down" })
vim.keymap.set({ "n" }, "<a-up>", "<cmd>m .-2<cr>==", { desc = "move up" })
vim.keymap.set({ "i" }, "<a-down>", "<esc><cmd>m .+1<cr>==gi", { desc = "move down" })
vim.keymap.set({ "i" }, "<a-up>", "<esc><cmd>m .-2<cr>==gi", { desc = "move up" })
vim.keymap.set({ "v" }, "<a-down>", ":m '>+1<cr>gv=gv", { desc = "move down" })
vim.keymap.set({ "v" }, "<a-up>", ":m '<-2<cr>gv=gv", { desc = "move up" })

-- buffers
vim.keymap.set({ "n" }, "[b", "<cmd>bprevious<cr>", { desc = "prev buffer" })
vim.keymap.set({ "n" }, "]b", "<cmd>bnext<cr>", { desc = "next buffer" })
