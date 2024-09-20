---@diagnostic disable: unused-function
local sysname = vim.uv.os_uname().sysname
local sys_icon = ""

-- show a system icon when using WSL because sometimes its confusing which os I'm on
if sysname == "Linux" and vim.g.wslenv then
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
end

local function colorize_path()
	local file_path = vim.fn.fnamemodify(vim.fn.expand('%:f'), ':.:h')
	local filename = vim.fn.expand('%:t')
	local scheme = ""

	local dir_color = "%#@punctuation#"
	local file_color = "%#@include#"
	local oil_color = "%#@text.note#"
	local term_color = "%#@attribute.builtin#"

	local dir = ""

	if vim.startswith(file_path, "oil://") then
		scheme = oil_color .. " 󱧯 %*"
		dir_color = oil_color
		if sysname == "Windows_NT" then
			file_path = file_path:sub(8) -- strip out 'oil:///'
			local drive_letter = file_path:sub(1, 1)
			file_path = drive_letter .. ':/' .. file_path:sub(3)
			file_path = vim.fs.normalize(vim.fn.fnamemodify(file_path, ":.:h"))
			dir = file_path .. " "
		else
			file_path = file_path:sub(7) -- strip out 'oil://'
			file_path = vim.fn.fnamemodify(file_path, ":.:h")
			dir = file_path .. " "
		end
	elseif vim.startswith(file_path, "term:") then
		scheme = term_color .. "  %*"
		dir_color = term_color
		file_path = file_path:sub(6) -- strip out 'term:/'
	else
		dir = vim.fs.normalize(file_path)
		if #filename > 0 then
			dir = dir .. "/"
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
  au WinLeave,BufLeave * setlocal statusline=%{substitute(expand('%f'),'\\\\','/','g')}
  augroup END
]], false)
