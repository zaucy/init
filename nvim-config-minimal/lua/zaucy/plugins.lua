local gh = function(x)
	return "https://github.com/" .. x
end

local cb = function(x)
	return "https://codeberg.org/" .. x
end

local modules_to_setup = {}

local function plugin_load(info)
	table.insert(modules_to_setup, info.spec.name)
	vim.opt.runtimepath:append(info.path)
	vim.cmd("packadd! " .. info.spec.name)
end

vim.pack.add({
	{ name = "oil", src = gh("barrettruth/canola.nvim") },
	{ name = "nvim-web-devicons", src = gh("nvim-tree/nvim-web-devicons") },
}, { load = plugin_load })

for _, plugin_name in ipairs(modules_to_setup) do
	local mod = require(plugin_name)
	local has_config_mod, config_mod = pcall(require, "zaucy." .. plugin_name)
	if not has_config_mod then
		if type(mod.setup) == "function" then
			local mod_setup_success, mod_setup_error = pcall(mod.setup, {})
			if not mod_setup_success then
				vim.notify(mod_setup_error, vim.log.levels.ERROR)
			end
		end
	else
		-- NOTE: should I do anything with the config mod?
		_ = config_mod
	end
end
