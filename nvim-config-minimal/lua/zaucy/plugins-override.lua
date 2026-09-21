local local_overrides = {}
local modules_to_setup = {}
local local_specs = {}

local function plugin_load(info)
	local plugin_name = info.spec.name
	table.insert(modules_to_setup, plugin_name)
	if local_overrides[plugin_name] then
		local local_path = local_overrides[plugin_name]

		-- Clear existing loaded modules for this plugin to force a reload
		for k, _ in pairs(package.loaded) do
			if k == plugin_name or k:match("^" .. vim.pesc(plugin_name) .. "%.") then
				package.loaded[k] = nil
			end
		end

		vim.opt.runtimepath:prepend(local_path)
		local after = local_path .. "/after"
		if vim.fn.isdirectory(after) == 1 then
			vim.opt.runtimepath:append(after)
		end

		if vim.loader then
			vim.loader.reset(local_path)
		end
	else
		vim.cmd("packadd! " .. plugin_name)
	end
end

local original_pack_get = vim.pack.get
---@diagnostic disable-next-line: duplicate-set-field
vim.pack.get = function(names, opts)
	local local_names = {}
	local remote_names = nil
	if names then
		remote_names = {}
		for _, n in ipairs(names) do
			if local_overrides[n] then
				table.insert(local_names, n)
			else
				table.insert(remote_names, n)
			end
		end
	end

	local results = {}
	if not remote_names or #remote_names > 0 then
		results = original_pack_get(remote_names, opts)
	end

	local present = {}
	for _, res in ipairs(results or {}) do
		local name = res.spec and res.spec.name
		if name then
			present[name] = true
			if local_overrides[name] then
				res.path = local_overrides[name]
				res.active = true
			end
		end
	end

	if names then
		for _, n in ipairs(local_names) do
			if not present[n] then
				table.insert(results, {
					active = true,
					path = local_overrides[n],
					rev = "",
					spec = local_specs[n] or { name = n, src = "" },
				})
			end
		end
	else
		for n, p in pairs(local_overrides) do
			if local_specs[n] and not present[n] then
				table.insert(results, {
					active = true,
					path = p,
					rev = "",
					spec = local_specs[n],
				})
			end
		end
	end

	return results
end

local original_pack_add = vim.pack.add
---@diagnostic disable-next-line: duplicate-set-field
vim.pack.add = function(specs, opts)
	opts = opts or {}
	assert(not opts.load, "zaucy plugins override doesn't allow vim.pack.add to set the opts.load fn")
	opts.load = plugin_load

	local remote_specs = {}
	for _, spec in ipairs(specs) do
		local name = (type(spec) == "table" and spec.name)
			or (type(spec) == "table" and spec.src and spec.src:match("[^/]+$"):gsub("%.git$", ""))
			or (type(spec) == "string" and spec:match("[^/]+$"):gsub("%.git$", ""))
		if local_overrides[name] and vim.fn.isdirectory(local_overrides[name]) == 1 then
			local plug_spec = type(spec) == "table" and spec or { name = name, src = spec }
			local_specs[name] = plug_spec
			plugin_load({ spec = plug_spec })
		else
			table.insert(remote_specs, spec)
		end
	end

	return original_pack_add(remote_specs, opts)
end

vim.pack.zaucy_mod_init = function()
	local local_configs = {}
	local cfg_dir = vim.fn.stdpath("config") .. "/lua/zaucy/plugins"
	for name, type in vim.fs.dir(cfg_dir) do
		if type ~= "directory" then
			local mod_name = name:match("^(.*)%.lua$")
			if mod_name then
				local_configs[mod_name] = true
			end
		end
	end

	for _, plugin_name in ipairs(modules_to_setup) do
		if local_configs[plugin_name] then
			local modname = "zaucy.plugins." .. plugin_name
			local has_config_mod, config_mod_or_error = pcall(require, modname)
			if not has_config_mod then
				vim.notify(config_mod_or_error, vim.log.levels.ERROR)
			else
				-- NOTE: should I do anything with the config mod?
				_ = config_mod_or_error
			end
		end
	end
end

return function(overrides)
	for name, path in pairs(overrides or {}) do
		local_overrides[name] = path
	end
end
