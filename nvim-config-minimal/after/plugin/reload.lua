local function reopen_neovide_detached()
	local current_file = vim.fn.expand("%:p")
	local args = { "--", "+ReloadDone " .. tostring(vim.uv.os_getppid()) }

	if current_file then
		table.insert(args, "--")
		table.insert(args, current_file)
	end

	print(vim.inspect(args))

	local handle = vim.uv.spawn("neovide", {
		cwd = vim.fn.getcwd(),
		args = args,
		detached = true,
		hide = true,
	})

	---@diagnostic disable-next-line: need-check-nil
	handle:unref()
end

local function reload_command()
	if vim.g.neovide then
		reopen_neovide_detached()
	end
end

local function reload_done_command(opts)
	if vim.g.neovide then
		vim.cmd(":NeovideFocus")
	end

	local reload_pid = tonumber(opts.fargs[1])

	---@diagnostic disable-next-line: param-type-mismatch
	vim.uv.kill(reload_pid, "sigkill")
end

local function update_command()
	vim.api.nvim_create_autocmd("User", {
		pattern = "LazySync",
		callback = function()
			vim.cmd("Reload")
		end,
	})

	vim.cmd("Lazy sync")
end

if not vim.g.vscode then
	vim.api.nvim_create_user_command("Reload", reload_command, {})
	vim.api.nvim_create_user_command("ReloadDone", reload_done_command, { nargs = 1 })
	vim.api.nvim_create_user_command("Update", update_command, {})
end
