local reload_buf = nil

local function update_reloading_dialog(_)
	require('zaucy.donut_load').donut_to_nvim_buf(reload_buf)
end

local function open_reloading_dialog()
	reload_buf = vim.api.nvim_create_buf('', true)
	local ui = vim.api.nvim_list_uis()[1]

	-- local width = math.max(math.floor(ui.width * 0.5), 120)
	-- local height = math.max(math.floor(ui.height * 0.5), 20)
	local width = 80
	local height = 24

	update_reloading_dialog()

	vim.api.nvim_open_win(reload_buf, true, {
		relative = 'editor',
		style = "minimal",
		border = "rounded",
		width = width,
		height = height,
		row = (ui.height / 2) - (height / 2),
		col = (ui.width / 2) - (width / 2),
		noautocmd = true,
	})

	local timer = vim.loop.new_timer()
	timer:start(10, 10, vim.schedule_wrap(update_reloading_dialog))
end

local function run_init_ps1(callback)
	local init_dir = vim.fn.environ().USERPROFILE .. "\\projects\\zaucy\\init"

	vim.loop.spawn(
		"pwsh",
		{
			cwd = init_dir,
			args = { "init.ps1" },
			hide = true,
		},
		function()
			vim.schedule(function()
				callback()
			end)
		end
	)
end

local function reopen_neovide_detached()
	local handle, pid = vim.loop.spawn("neovide", {
		cwd = vim.loop.cwd(),
		args = {},
		detached = true,
		hide = true,
	})

	print("Spawned neovide pid:", pid)
	handle:unref()
end

local function quit_neovim_now()
	vim.api.nvim_command(":qa")
end

local function reload_command()
	local sysname = vim.loop.os_uname().sysname

	if sysname == "Windows_NT" then
		open_reloading_dialog()
		run_init_ps1(function()
			reopen_neovide_detached()
			quit_neovim_now()
		end)
	end
end

vim.api.nvim_create_user_command("Reload", reload_command, {})
