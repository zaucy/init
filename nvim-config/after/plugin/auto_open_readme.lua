local buf = vim.api.nvim_get_current_buf()
local buf_readonly = vim.api.nvim_buf_get_option(buf, 'readonly')

if buf_readonly then
	local readme_file = vim.fs.find("README.md")
	if readme_file[1] ~= nil then
		vim.cmd('n ' .. readme_file[1])
	end
end
