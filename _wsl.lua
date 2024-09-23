local _, _, wslenv_err = vim.uv.os_getenv("WSLENV", 1)
if wslenv_err ~= nil and wslenv_err == "ENOENT" then
	vim.g.wslenv = false
else
	vim.g.wslenv = true
end
