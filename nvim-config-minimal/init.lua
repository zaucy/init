_G.zaucy = {}

-- local orig_uri_to_fname = vim.uri_to_fname
-- vim.uri_to_fname = function(uri)
-- 	local fname = orig_uri_to_fname(uri)
-- 	if not fname then
-- 		return nil
-- 	end
--
-- 	if vim.startswith(uri, "file://") then
-- 		local cwd = vim.fn.getcwd():gsub("\\", "/")
--
-- 		if not vim.startswith(fname, cwd) then
-- 			local bazel = require("bazel")
-- 			local bazel_root = bazel.bazel_root(cwd)
--
-- 			fname = string.gsub(fname, "\\", "/")
--
-- 			if bazel_root then
-- 				local info = bazel.info_cached()
-- 				if info and info["bazel-bin"] then
-- 					-- print(fname)
-- 					-- print(info["bazel-bin"])
-- 					if vim.startswith(string.lower(fname), string.lower(info["bazel-bin"])) then
-- 						return vim.fs.joinpath(bazel_root, "bazel-bin", string.sub(fname, #info["bazel-bin"] - 2))
-- 					end
-- 				end
-- 			else
-- 				local stat = vim.uv.fs_stat(fname)
-- 				if stat then
-- 					if stat.type == "link" then
-- 						local real_path = vim.uv.fs_readlink(fname)
-- 						if real_path then
-- 							return real_path:gsub("\\", "/")
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
--
-- 	return fname
-- end

require("config.options")
require("config.lazy")
require("config.keymaps")
require("zaucy.term")
require("zaucy.treesitter-parsers")
require("zaucy.screenshot")

require("zaucy.chat").setup({
	chat_scratch_dir = vim.fn.substitute(vim.fn.expand("~/projects/zaucy/init/scratch/chat"), "\\\\", "/", "g"),
	terminal_command = "gemini",
})

vim.api.nvim_create_autocmd("User", {
	pattern = "McpServerCreated",
	callback = function(args)
		local cwd = args.data.cwd
		require("zaucy.chat").set_dir_loading(cwd, true)
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "McpServerReady",
	callback = function(args)
		local cwd = args.data.cwd
		require("zaucy.chat").set_dir_loading(cwd, false)
	end,
})
