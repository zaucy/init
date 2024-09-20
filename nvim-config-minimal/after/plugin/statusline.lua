---@diagnostic disable: unused-function
local sysname = vim.uv.os_uname().sysname
local sys_icon = ""

if sysname == "Linux" then
	local distro_name = ""
	local file = io.open("/etc/os-release", "r")
	if not file then return nil end

	for line in file:lines() do
		if line:match("^ID=") then
			distro_name = line:match("^ID=(.+)"):gsub('"', '')
			break
		end
	end

	file:close()

	if distro_name == "ubuntu" then
		sys_icon = "%#DevIconUbuntu# %*"
	else
		sys_icon = "%#DevIconUbuntu# %*"
	end
elseif sysname == "Windows" then
	sys_icon = "%#DevIconWindows# %*"
end

local function colorize_path()
	local file_path = vim.fn.expand('%:f')
	local filename = vim.fn.expand('%:t')
	local scheme = ""

	local dir_color = "%#Comment#"
	local file_color = "%#@include#"
	local oil_color = "%#@text.note#"

	local dir = ""

	if vim.startswith(file_path, "oil://") then
		scheme = oil_color .. " 󱧯 %*"
		dir_color = oil_color
		file_path = file_path:sub(7) -- strip out 'oil://'
		file_path = vim.fn.fnamemodify(file_path, ":.:h")
		dir = file_path .. " "
	else
		dir = file_path:sub(1, #file_path - #filename - 1)
		if #filename > 0 then
			dir = dir .. "/"
		else
			dir = "[No Name]"
		end
	end


	return scheme .. dir_color .. dir .. file_color .. filename
end

function ZaucyStatusline()
	return sys_icon .. colorize_path() .. [[%* %h%m%r %=%-14.(%l,%c%V%) %P]]
end

vim.cmd([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.ZaucyStatusline()
  au WinLeave,BufLeave * setlocal statusline=%f
  augroup END
]], false)
