local M = {}

--- @param name string
--- @return string|nil
local function check_bazel_paths(name)
	if vim.startswith(name, "@bazel-") then
		return name:sub(2)
	end

	local cwd = vim.uv.cwd()
	local bzlmod_file = cwd .. "/MODULE.bazel"
	if vim.fn.exists(bzlmod_file) then
		local result = vim.system({ "bazel", "info", "execution_root" }, { text = true, cwd = cwd }):wait()
		if result.code == 0 and result.stdout then
			local exec_root = vim.trim(result.stdout)
			local bazel_root_path = exec_root .. "/" .. name
			if vim.fn.exists(bazel_root_path) then
				return bazel_root_path
			end
		end
	end

	return nil
end

--- @param name string
--- @return string
function M.include(name)
	local found_path
	found_path = check_bazel_paths(name)
	if found_path then
		return found_path
	end

	return name
end

return M
