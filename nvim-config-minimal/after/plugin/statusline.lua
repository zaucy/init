---@diagnostic disable: unused-function
local sysname = vim.uv.os_uname().sysname
local homedir = vim.fn.substitute(vim.fn.expand("~"), "\\\\", "/", "g")
local sys_icon = ""

-- show a system icon when using WSL because sometimes its confusing which os I'm on
if sysname == "Linux" and vim.g.wslenv then
	local distro_name = ""
	local file = io.open("/etc/os-release", "r")
	if not file then
		return nil
	end

	for line in file:lines() do
		if line:match("^ID=") then
			distro_name = line:match("^ID=(.+)"):gsub('"', "")
			break
		end
	end

	file:close()

	if distro_name == "ubuntu" then
		sys_icon = "%#DevIconUbuntu# %*"
	else
		sys_icon = "%#DevIconUbuntu# %*"
	end
end

local function colorize_path()
	local winid = vim.g.statusline_winid or 0
	local tabpage = vim.api.nvim_win_get_tabpage(winid)
	local has_tabpage_cwd, tabpage_cwd = pcall(vim.fn.getcwd, -1, tabpage)
	local bufnr = vim.api.nvim_win_get_buf(winid)
	local scheme = ""

	local file_path = vim.api.nvim_buf_get_name(bufnr)
	local filename = vim.fs.basename(file_path)

	-- file_path = vim.fn.substitute(file_path, "\\\\", "/", "g")
	file_path = file_path:gsub("\\", "/")

	local dir_color = "%#@punctuation#"
	local file_color = "%#@include#"
	local oil_color = "%#@text.note#"
	local term_color = "%#@attribute.builtin#"
	local git_color = "%#GitSignsAdd#"
	local config_color = "%#GitSignsAdd#"

	local dir = ""

	if vim.startswith(file_path, "oil://") then
		scheme = oil_color .. " 󱧯 %*"
		dir_color = oil_color
		if sysname == "Windows_NT" then
			file_path = file_path:sub(8) -- strip out 'oil:///'
			local drive_letter = file_path:sub(1, 1)
			file_path = drive_letter .. ":/" .. file_path:sub(3)
			file_path = vim.fs.normalize(vim.fn.fnamemodify(file_path, ":.:h"))
			dir = file_path .. " "
		else
			file_path = file_path:sub(7) -- strip out 'oil://'
			file_path = vim.fn.fnamemodify(file_path, ":.:h")
			dir = file_path .. " "
		end
	elseif vim.startswith(file_path, "gitsigns://") then
		scheme = term_color .. "  %*"
		dir_color = git_color
		file_path = file_path:sub(11) -- strip out 'gitsigns://'
		local _, path_start, head = file_path:find("//(.+):")
		scheme = scheme .. head .. " "
		dir = file_path:sub(path_start + 1)
		filename = ""
	elseif vim.startswith(file_path, "codediff://") then
		scheme = term_color .. "  %*"
		dir_color = git_color
		file_path = file_path:sub(11) -- strip out 'codediff://'
		dir = vim.fs.normalize(vim.fn.fnamemodify(file_path:sub(2, #file_path - #filename), ":.:h")):sub(6) .. "/"
	elseif vim.startswith(file_path, "diffview://") then
		scheme = term_color .. "  %*"
		dir_color = git_color
		file_path = file_path:sub(11) -- strip out 'diffview://'
		dir = vim.fs.normalize(vim.fn.fnamemodify(file_path:sub(2, #file_path - #filename), ":.:h")):sub(6) .. "/"
	elseif vim.startswith(file_path, "term:") then
		scheme = term_color .. "  %*"
		dir_color = term_color
		file_path = file_path:sub(6) -- strip out 'term:/'
	else
		if has_tabpage_cwd then
			local rel_file_path = vim.fs.relpath(tabpage_cwd, file_path)
			if rel_file_path ~= nil then
				file_path = rel_file_path
			end
		end

		if vim.startswith(file_path, homedir) then
			file_path = "~" .. file_path:sub(#homedir + 1)
		end
		dir = file_path:sub(1, #file_path - #filename - 1)
		if #filename > 0 then
			dir = dir .. "/"
		end

		local nvim_config_prefix = "~/projects/zaucy/init/nvim-config-minimal/"
		if vim.startswith(dir, nvim_config_prefix) then
			dir = dir:sub(#nvim_config_prefix + 1)
			scheme = config_color .. " 󰒔 %*"
		end
	end

	return scheme .. dir_color .. dir .. file_color .. filename
end

function ZaucyStatusline()
	local status_str = sys_icon .. colorize_path() .. [[%* %h%m%r %=%-14.(%l,%c%V%) %P]]
	if package.loaded.dap then
		local session = require("dap").session()
		if session ~= nil then
			status_str = "%#@text.danger#" .. status_str
		end
	end
	return status_str
end

vim.o.laststatus = 2
vim.o.statusline = "%!v:lua.ZaucyStatusline()"
