local function make_reopen_neovide_detached_fn()
	if not vim.g.neovide then
		return function() end
	end

	local current_file = vim.fn.expand("%:p"):gsub("\\", "/")
	local neovide_args = {}
	local files = {}

	if vim.g.wslenv then
		table.insert(neovide_args, "--wsl")
	end

	if current_file then
		local _, line, col = unpack(vim.fn.getcursorcharpos())
		table.insert(files, { current_file, line, col })
	end

	local nvim_args = {}

	if vim.g.zaucy_streamer_mode then
		table.insert(nvim_args, "+StreamerMode")
		table.insert(neovide_args, "--frame=none")
		table.insert(neovide_args, "--size=2000x1370")
	end

	-- TODO: This just plain doesn't work with neovide --wsl
	if not vim.g.wslenv then
		table.insert(nvim_args, "+ReloadDone " .. tostring(vim.uv.os_getppid() .. " " .. vim.json.encode(files)))
	end

	table.insert(neovide_args, "--")
	for _, nvim_arg in ipairs(nvim_args) do
		table.insert(neovide_args, nvim_arg)
	end
	return function()
		local neovide_exe = "neovide"
		if vim.g.wslenv then
			-- TODO: do a 'where' in cmd or something on the windows side to find the preferred neovide executable
			neovide_exe = "/mnt/c/Users/zekew/.cargo/bin/neovide.exe"
		end

		local handle = vim.uv.spawn(neovide_exe, {
			cwd = vim.fn.getcwd(),
			args = neovide_args,
			detached = true,
			hide = true,
		})

		if handle ~= nil then
			handle:unref()
		else
			vim.notify("failed to spawn neovide", vim.log.levels.ERROR)
		end

		if vim.g.wslenv then
			local timer = vim.uv.new_timer()
			timer:start(1000, 0, function()
				vim.schedule(function()
					vim.cmd [[qa!]]
				end)
			end)
		end
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
		if file and #vim.trim(file) > 0 then
			vim.cmd.edit(file)
			pcall(vim.api.nvim_win_set_cursor, 0, { line, col - 1 })
		end
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
	vim.api.nvim_create_user_command("Reload", reload_command,
		{ desc = "Restarts neovide and re-opens the currently focused buffer" })
	vim.api.nvim_create_user_command("ReloadDone", reload_done_command,
		{ nargs = '*', desc = "internal: Used when running neovide command to do startup stuff after reload" })
	vim.api.nvim_create_user_command("Update", update_command, { desc = "Pulls changes from init repo and run LazySync" })
end
