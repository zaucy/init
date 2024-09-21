---@diagnostic disable: unused-function
local sysname = vim.uv.os_uname().sysname
local homedir = vim.fn.substitute(vim.fn.expand('~'), '\\\\', '/', 'g')
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
	local file_path = vim.fn.expand('%:f')
	local filename = vim.fn.expand('%:t')
	local scheme = ""

	local dir_color = "%#@punctuation#"
	local file_color = "%#@include#"
	local oil_color = "%#@text.note#"
	local term_color = "%#@attribute.builtin#"
	local git_color = "%#GitSignsAdd#"

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
	elseif vim.startswith(file_path, "gitsigns://") then
		scheme = term_color .. "  %*"
		dir_color = git_color
		file_path = file_path:sub(11) -- strip out 'gitsigns://'
		local _, path_start, head = file_path:find("//(.+):")
		scheme = scheme .. head .. " "
		dir = file_path:sub(path_start + 1)
		filename = ""
	elseif vim.startswith(file_path, "term:") then
		scheme = term_color .. "  %*"
		dir_color = term_color
		file_path = file_path:sub(6) -- strip out 'term:/'
	else
		file_path = vim.fn.substitute(file_path, '\\\\', '/', 'g')
		if vim.startswith(file_path, homedir) then
			file_path = '~' .. file_path:sub(#homedir + 1)
		end
		dir = file_path:sub(1, #file_path - #filename - 1)
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
