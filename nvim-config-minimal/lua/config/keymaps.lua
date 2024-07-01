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

local function is_bufvalid(buf)
	if buf == nil then return false end
	if not vim.api.nvim_buf_is_valid(buf) then return false end
	local buftype = vim.bo[buf].buftype
	if buftype == "prompt" then return false end
	if buftype == "nofile" then return false end
	print(buftype)
	return true
end

local function find_nearby_valid_buf(bufs, start_index)
	local offset = 1
	while true do
		if start_index + offset > #bufs and start_index - offset < 0 then
			return nil
		end

		if is_bufvalid(bufs[start_index + offset]) then
			return bufs[start_index + offset]
		elseif is_bufvalid(bufs[start_index - offset]) then
			return bufs[start_index - offset]
		end

		offset = offset + 1
	end
end

local function close_terminal()
	if vim.bo.buftype ~= "terminal" then
		return
	end

	local currbuf = vim.fn.winbufnr(0)
	local allbufs = vim.api.nvim_list_bufs()
	for i, buf in ipairs(allbufs) do
		if buf == currbuf then
			local nearby_buf = find_nearby_valid_buf(allbufs, i)
			if nearby_buf ~= nil then
				vim.api.nvim_set_current_buf(nearby_buf)
			else
				vim.cmd.close()
			end
			return
		end
	end

	vim.cmd.close()
end

local function open_terminal()
	if vim.bo.buftype == "terminal" then
		close_terminal()
		return
	end

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buftype == "terminal" then
			vim.api.nvim_set_current_buf(buf)
			return
		end
	end

	vim.cmd("terminal")
end

vim.keymap.set({ "n" }, "<C-_>", open_terminal, { desc = "Open Terminal" })
vim.keymap.set({ "n" }, "<C-/>", open_terminal, { desc = "Open Terminal" })
vim.keymap.set({ "t" }, "<esc><esc>", "<C-\\><C-n>", { desc = "Enter Normal Mode" })
vim.keymap.set({ "t" }, "<C-w>", "<C-\\><C-n><cmd>WhichKey <C-w><cr>", {})
vim.keymap.set({ "t" }, "<C-/>", close_terminal, { desc = "Hide Terminal" })
vim.keymap.set({ "t" }, "<C-_>", close_terminal, { desc = "Hide Terminal" })

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
