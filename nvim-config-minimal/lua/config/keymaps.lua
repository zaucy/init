vim.cmd("highlight ZaucySubstituteSelect guibg=#151521")

local config_dir = vim.fn.expand("~/projects/zaucy/init/nvim-config-minimal")

vim.keymap.set({ "v" }, '/', '<esc>/\\%V') -- search in selection

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

local function bazel_override()
	vim.ui.input({}, function(input)
		if not input then return end
		goto_closest_file("MODULE.bazel")()
		vim.cmd("!bzloverride " ..  input)
		vim.fn.feedkeys("G", "n")
	end)
end

local function bzlmod_add()
	vim.ui.input({}, function(input)
		if not input then return end
		goto_closest_file("MODULE.bazel")()
		vim.cmd("!bzlmod add " ..  input)
	end)
end

vim.keymap.set({ "n" }, "gbb", goto_closest_file("BUILD.bazel"), { desc = "Bazel Build File" })
vim.keymap.set({ "n" }, "gbm", goto_closest_file("MODULE.bazel"), { desc = "Bazel Module File" })
vim.keymap.set({ "n" }, "gbw", goto_closest_file("WORKSPACE.bazel"), { desc = "Bazel Workspace File" })
vim.keymap.set({ "n" }, "gbz", goto_closest_file(".bazelrc"), { desc = "Bazelrc File" })
vim.keymap.set({ "n" }, "gsh", "<cmd>LspClangdSwitchSourceHeader<cr>", { desc = "clangd switch source header" })

vim.keymap.set({ "n" }, "gbo", bazel_override, { desc = "Bazel Override" })
vim.keymap.set({ "n" }, "gba", bzlmod_add, { desc = "Bazel Override" })

vim.keymap.set({ "c" }, "<C-c>", "<C-q><C-c>")

vim.keymap.set({ "n", "v" }, "<leader>qd", "<cmd>BazelDebug<cr>",
	{ desc = "Build and launch bazel target with nvim-dap" })

vim.keymap.set({"n", "v" }, "<leader>ypr", function() vim.fn.setreg("+", vim.fn.expand("%")) end,  { desc = "yank current relative file path"})
vim.keymap.set({"n", "v" }, "<leader>ypa", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end,  { desc = "yank current absolute file path"})
vim.keymap.set({"n", "v" }, "<leader>ypf", function() vim.fn.setreg("+", vim.fn.expand("%:t")) end, { desc = "yank current file name "})
vim.keymap.set({"n", "v" }, "<leader>ypd", function() vim.fn.setreg("+", vim.fn.expand("%:h")) end, { desc = "yank current file dirname"})

for i = 1, 9 do
	vim.keymap.set({ "n", "v", "t" }, "<C-" ..tostring(i) .. ">", function() require('zaucy.tabline').goto(i) end, { desc = "Goto tab " .. tostring(i) })
end

local function tonumber_safe(v)
	local _, n = pcall(tonumber, v)
	return n
end

local function do_fzf(cmd, opts)
	opts = opts or {}
	return function()
		local original_buf = vim.api.nvim_get_current_buf()
		local buf = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_set_current_buf(buf)

		local fzf_cmd = {"fzf", "--no-mouse"}
		if opts.fzf_args then
			for _, arg in ipairs(opts.fzf_args) do
				table.insert(fzf_cmd, arg)
			end
		end

		local channel_id = vim.fn.jobstart(fzf_cmd, {
			term = true,
			stdout_buffered = false,
			cwd = opts.cwd,
			env = {
				FZF_DEFAULT_COMMAND = cmd,
				-- FZF_DEFAULT_OPTS = FZF_DEFAULT_OPTS,
			},
			on_exit = function(_, code, _)
				if code == 0 then
					local line = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]:gsub("\\", "/")
					local info = vim.json.decode(line)
					local file_path = vim.fn.fnameescape(info.filename)
					local full_path = file_path
					if opts.cwd then
						full_path = vim.fs.joinpath(opts.cwd, file_path)
					end
					vim.cmd.edit(full_path)

					if info.line ~= nil or info.col ~= nil then
						local line_num = tonumber_safe(info.line) or 1
						local col_num = (tonumber_safe(info.col) or 1) - 1
						vim.api.nvim_win_set_cursor(0, {line_num, col_num})
					end
					vim.api.nvim_buf_delete(buf, {force = true, unload = true})
				elseif code == 130 then
					vim.api.nvim_set_current_buf(original_buf)
					vim.api.nvim_buf_delete(buf, {force = true, unload = true})
				end
			end,
		  })

		if channel_id > 0 then
			vim.cmd.startinsert()
		end
	end
end

vim.keymap.set(
	{"n", "v"},
	"<C-w>ff",
	do_fzf("rg --files", {
		fzf_args = {
			"--preview", "bat --style=numbers --color=always --line-range :500 {}",
			"--preview-window", "up:75%",
			"--bind", "enter:become(echo {\"filename\": {+1}})",
		},
	}),
	{ desc = "open fzf files" }
)

vim.keymap.set(
	{"n", "v"},
	"<C-w>fc",
	do_fzf("rg --files", {
		cwd = config_dir,
		fzf_args = {
			"--preview", "bat --style=numbers --color=always --line-range :500 {}",
			"--preview-window", "up:75%",
			"--bind", "enter:become(echo {\"filename\": {+1}})",
		},
	}),
	{ desc = "open fzf (config)" }
)

vim.keymap.set(
	{"n", "v"},
	"<C-w>/",
	do_fzf("rg --column", {
		fzf_args = {
			"--preview", "bat --style=numbers --color=always --highlight-line {2} {1}",
			"--preview-window", "~4,+{2}+4/3,up:75%",
			"--bind", "change:reload:rg --column {q}",
			"--bind", "enter:become(echo {\"filename\": {+1}, \"line\": {+2}, \"col\": {+3}})",
			"--delimiter", ":",
		},
	}),
	{ desc = "open search window" }
)

local function is_buf_similar(buf1, buf2)
	if vim.bo[buf1].buftype ~= vim.bo[buf2].buftype then
		return false
	end

	if vim.bo[buf1].filetype ~= vim.bo[buf2].filetype then
		return false
	end

	return true
end

local function wrap_access(list, index)
	-- zero-base this nerd
	index = index - 1
	local wrapped_index = index % #list
	return list[wrapped_index + 1]
end

local function find_similar_buf(bufs, start_index, offset)
	assert(start_index ~= nil, "start_index must be set")
	assert(start_index > 0, "start_index must be greater than 0")
	assert(start_index <= #bufs, "start_index must be within bufs range")
	if #bufs < 2 then
		return nil
	end

	local curbuf = vim.api.nvim_get_current_buf()

	offset = offset or 1
	for i = 0, #bufs - 1 do
		local buf = wrap_access(bufs, start_index + i + offset)
		if buf ~= curbuf and is_bufvalid(buf) then
			if is_buf_similar(0, buf) then
				return buf
			end
		end
	end

	return nil
end

local function get_buf_index(buf, bufs)
	if buf == 0 then
		buf = vim.api.nvim_get_current_buf()
	end

	assert(buf ~= nil)

	if bufs == nil then
		bufs = vim.api.nvim_list_bufs()
	end

	for i, _ in ipairs(bufs) do
		if bufs[i] == buf then
			return i
		end
	end

	return nil
end

local function goto_next_similar_buffer()
	local bufs = vim.api.nvim_list_bufs()
	local curr_index = get_buf_index(0, bufs)
	local buf = find_similar_buf(bufs, curr_index, 1)
	if buf == nil then
		vim.notify(
			"No other similar buffers (buftype=" .. vim.bo.buftype .. ", filetype=" .. vim.bo.filetype .. ")",
			vim.log.levels.WARN
		)
		return
	end
	vim.api.nvim_set_current_buf(buf)
end

local function goto_prev_similar_buffer()
	local bufs = vim.api.nvim_list_bufs()
	local curr_index = get_buf_index(0, bufs)
	local buf = find_similar_buf(bufs, curr_index, -1)
	if buf == nil then
		vim.notify(
			"No other similar buffers (buftype=" .. vim.bo.buftype .. ", filetype=" .. vim.bo.filetype .. ")",
			vim.log.levels.WARN
		)
		return
	end
	vim.api.nvim_set_current_buf(buf)
end

-- vim.keymap.set({ "n" }, "]]", goto_next_similar_buffer, { desc = "Next Similar Buf" })
-- vim.keymap.set({ "n" }, "[[", goto_prev_similar_buffer, { desc = "Next Similar Buf" })

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

-- lsp
vim.keymap.set({ "n" }, "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" })
vim.keymap.set({ "n" }, "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
vim.keymap.set({ "n" }, "gi", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
vim.keymap.set({ "n" }, "gri", vim.lsp.buf.incoming_calls, { desc = "vim.lsp.buf.incoming_calls()" })
vim.keymap.set({ "n" }, "gro", vim.lsp.buf.outgoing_calls, { desc = "vim.lsp.buf.outgoing_calls()" })
vim.keymap.set({ "n" }, "grr", "<cmd>Telescope lsp_references<cr>", { desc = "vim.lsp.buf.outgoing_calls()" })
-- vim.keymap.set({ "n" }, "grn", ":IncRename ", { desc = "rename" })
vim.keymap.set(
	{ "n", "v" },
	"<leader>S",
	function() require('zaucy.lsp').dynamic_workspace_symbols({ theme = "ivy" }) end,
	{ desc = "Workspace symbols" }
)

vim.keymap.set(
	{ "n" },
	"grs",
	function()
		require('zaucy.lsp').dynamic_workspace_symbols({
			default_text = vim.fn.expand("<cword>"),
			theme = "ivy",
		})
	end,
	{ desc = "Workspace symbols" }
)

vim.keymap.set(
	{ "n" },
	"gr/",
	function()
		require('telescope.builtin').live_grep({
			default_text = vim.fn.expand("<cword>"),
			theme = "ivy",
		})
	end,
	{ desc = "Workspace symbols" }
)

-- quickfix
vim.keymap.set({ "n" }, "[q", "<cmd>cprevious<cr>", { desc = "prev qf item" })
vim.keymap.set({ "n" }, "]q", "<cmd>cnext<cr>", { desc = "next qf item" })

-- some script runners
vim.keymap.set({ "n", "v" }, "<C-S-B>", function() end, { desc = "" })

-- similar to alacritty escape
vim.keymap.set({ "t" }, "<C-S-Space>", "<C-\\><C-n>", { desc = "" })

-- arrow keys for window stuff
vim.keymap.set({ "n", "v" }, "<C-w><cr>", "<cmd>only<cr>", { desc = "Close other windows" })
vim.keymap.set({ "n", "v" }, "<C-w><C-left>", "<cmd>wincmd H<cr>", { desc = "Move window to the far left" })
vim.keymap.set({ "n", "v" }, "<C-w><C-down>", "<cmd>wincmd J<cr>", { desc = "Move window to the far bottom" })
vim.keymap.set({ "n", "v" }, "<C-w><C-up>", "<cmd>wincmd K<cr>", { desc = "Move window to the far top" })
vim.keymap.set({ "n", "v" }, "<C-w><C-right>", "<cmd>wincmd L<cr>", { desc = "Move window to the far right" })
