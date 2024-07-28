local function make_reopen_neovide_detached_fn()
	if not vim.g.neovide then
		return function() end
	end

	local current_file = vim.fs.normalize(vim.fn.expand("%:p"))
	local reload_done_cmd = "+ReloadDone " .. tostring(vim.uv.os_getppid())
	local files = {}

	if current_file then
		local _, line, col = unpack(vim.fn.getcursorcharpos())
		table.insert(files, { current_file, line, col })
	end

	reload_done_cmd = reload_done_cmd .. " " .. vim.json.encode(files)
	return function()
		local handle = vim.uv.spawn("neovide", {
			cwd = vim.fn.getcwd(),
			args = { "--", reload_done_cmd },
			detached = true,
			hide = true,
		})

		---@diagnostic disable-next-line: need-check-nil
		handle:unref()
	end
end

local function reload_command()
	if vim.g.neovide then
		make_reopen_neovide_detached_fn()()
	end
end

local function reload_done_command(opts)
	if vim.g.neovide then
		vim.cmd(":NeovideFocus")
	end

	local reload_pid = tonumber(opts.fargs[1])

	---@diagnostic disable-next-line: param-type-mismatch
	vim.uv.kill(reload_pid, "sigkill")

	for _, entry in ipairs(vim.json.decode(opts.fargs[2])) do
		local file, line, col = unpack(entry)
		vim.cmd("e " .. file)
		vim.api.nvim_win_set_cursor(0, { line, col - 1 })
	end
end

local function update_command()
	local reload = make_reopen_neovide_detached_fn()
	vim.uv.spawn("git", {
		cwd = vim.fs.normalize("~/projects/zaucy/init"),
		args = { "pull" },
		hide = true,
	}, vim.schedule_wrap(function(_, _)
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazySync",
			callback = function()
				reload()
			end,
		})

		vim.cmd("Lazy sync")
	end))
end

if not vim.g.vscode then
	vim.api.nvim_create_user_command("Reload", reload_command, {})
	vim.api.nvim_create_user_command("ReloadDone", reload_done_command, { nargs = '*' })
	vim.api.nvim_create_user_command("Update", update_command, {})
end
