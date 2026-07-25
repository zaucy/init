local fns = require("config.keymap_fns")

local config_dir = vim.fn.expand("~/projects/zaucy/init/nvim-config-minimal")
local restart_session_file = vim.fn.stdpath("state") .. "/RestartSession.vim"

vim.keymap.set({ "v" }, '/', '<esc>/\\%V') -- search in selection

vim.keymap.set({"n", "v"}, "<C-S-U>", function() vim.pack.update(nil) end, { desc = "Update all packages" })

vim.keymap.set({"n", "v"}, "<leader>e", "<cmd>Oil<cr>", { desc = "Explore Files" })
vim.keymap.set({"n", "v"}, "<leader>E", "<cmd>Oil .<cr>", { desc = "Explore Files (PWD)" })

vim.keymap.set({ "n" }, "gbb", fns.goto_closest_file("BUILD.bazel"), { desc = "Bazel Build File" })
vim.keymap.set({ "n" }, "gbm", fns.goto_closest_file("MODULE.bazel"), { desc = "Bazel Module File" })
vim.keymap.set({ "n" }, "gbw", fns.goto_closest_file("WORKSPACE.bazel"), { desc = "Bazel Workspace File" })
vim.keymap.set({ "n" }, "gbz", fns.goto_closest_file(".bazelrc"), { desc = "Bazelrc File" })
vim.keymap.set({ "n" }, "gsh", "<cmd>LspClangdSwitchSourceHeader<cr>", { desc = "clangd switch source header" })
vim.keymap.set({ "n", "v" }, "gbe", fns.goto_bazel_file, { desc = "goto bazel file from bazel info (exec, etc.)" })

vim.keymap.set({ "n" }, "gbo", fns.bazel_override, { desc = "Bazel Override" })
vim.keymap.set({ "n" }, "gba", fns.bzlmod_add, { desc = "Bazel Override" })

vim.keymap.set({ "c" }, "<C-c>", "<C-q><C-c>")

vim.keymap.set({ "n", "v" }, "<leader>qd", "<cmd>BazelDebug<cr>", { desc = "Build and launch bazel target with nvim-dap" })

vim.keymap.set({"n", "v" }, "<leader>ypr", function() vim.fn.setreg("+", vim.fn.expand("%")) end,  { desc = "yank current relative file path"})
vim.keymap.set({"n", "v" }, "<leader>ypa", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end,  { desc = "yank current absolute file path"})
vim.keymap.set({"n", "v" }, "<leader>ypf", function() vim.fn.setreg("+", vim.fn.expand("%:t")) end, { desc = "yank current file name "})
vim.keymap.set({"n", "v" }, "<leader>ypd", function() vim.fn.setreg("+", vim.fn.expand("%:h")) end, { desc = "yank current file dirname"})

for i = 1, 9 do
	vim.keymap.set({ "n", "v", "t" }, "<C-" ..tostring(i) .. ">", function() require('zaucy.tabline').goto(i) end, { desc = "Goto tab " .. tostring(i) })
end

vim.keymap.set(
	{"n", "v"},
	"<C-w>ff",
	fns.do_fzf("rg --files", {
		fzf_args = {
			"--preview", "bat --style=numbers --color=always --line-range :500 {}",
			"--preview-window", "up:75%",
			"--bind", "enter:become(echo {\"filename\": {+1}})",
		},
	}),
	{ desc = "open fzf files" }
)

vim.keymap.set(
	{"n", "v"},
	"<C-w>fc",
	fns.do_fzf("rg --files", {
		cwd = config_dir,
		fzf_args = {
			"--preview", "bat --style=numbers --color=always --line-range :500 {}",
			"--preview-window", "up:75%",
			"--bind", "enter:become(echo {\"filename\": {+1}})",
		},
	}),
	{ desc = "open fzf (config)" }
)

vim.keymap.set({"n", "v"}, "<leader>ss", function() require("multibuffer.plugins.symbols").multibuf_document_symbols({}) end)
vim.keymap.set({"n", "v"}, "<leader>sf", function() require("multibuffer.plugins.symbols").multibuf_document_symbols({ kinds = { "Function", "Method", "Constructor"} }) end)
vim.keymap.set({"n", "v"}, "<leader>st", function() require("multibuffer.plugins.symbols").multibuf_document_symbols({ kinds = { "Class", "Interface", "Struct" } }) end)

-- move lines
vim.keymap.set({ "n" }, "<a-j>", "<cmd>m .+1<cr>==", { desc = "move down" })
vim.keymap.set({ "n" }, "<a-k>", "<cmd>m .-2<cr>==", { desc = "move up" })
vim.keymap.set({ "i" }, "<a-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "move down" })
vim.keymap.set({ "i" }, "<a-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "move up" })
vim.keymap.set({ "v" }, "<a-j>", ":m '>+1<cr>gv=gv", { desc = "move down" })
vim.keymap.set({ "v" }, "<a-k>", ":m '<-2<cr>gv=gv", { desc = "move up" })

vim.keymap.set({ "n" }, "<a-down>", "<cmd>m .+1<cr>==", { desc = "move down" })
vim.keymap.set({ "n" }, "<a-up>", "<cmd>m .-2<cr>==", { desc = "move up" })
vim.keymap.set({ "i" }, "<a-down>", "<esc><cmd>m .+1<cr>==gi", { desc = "move down" })
vim.keymap.set({ "i" }, "<a-up>", "<esc><cmd>m .-2<cr>==gi", { desc = "move up" })
vim.keymap.set({ "v" }, "<a-down>", ":m '>+1<cr>gv=gv", { desc = "move down" })
vim.keymap.set({ "v" }, "<a-up>", ":m '<-2<cr>gv=gv", { desc = "move up" })

-- buffers
vim.keymap.set({ "n" }, "[b", "<cmd>bprevious<cr>", { desc = "prev buffer" })
vim.keymap.set({ "n" }, "]b", "<cmd>bnext<cr>", { desc = "next buffer" })

-- lsp
-- vim.keymap.set({ "n" }, "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" })
vim.keymap.set({ "n" }, "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
-- vim.keymap.set({ "n" }, "gi", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
-- vim.keymap.set({ "n" }, "gri", vim.lsp.buf.incoming_calls, { desc = "vim.lsp.buf.incoming_calls()" })
-- vim.keymap.set({ "n" }, "gro", vim.lsp.buf.outgoing_calls, { desc = "vim.lsp.buf.outgoing_calls()" })
-- vim.keymap.set({ "n" }, "grr", "<cmd>Telescope lsp_references<cr>", { desc = "vim.lsp.buf.outgoing_calls()" })

vim.keymap.set('n', 'grr', function() require('multibuffer.plugins.lsp').references() end)
vim.keymap.set('n', 'gi', function() require('multibuffer.plugins.lsp').implementation() end)
vim.keymap.set('n', 'gri', function() require('multibuffer.plugins.lsp').incoming_calls() end)
vim.keymap.set('n', 'gro', function() require('multibuffer.plugins.lsp').outgoing_calls() end)

vim.keymap.set("n", "<leader>/", function() require("multibuffer.plugins.ripgrep").multibuf_ripgrep({}) end, { desc = "Global search" })

-- vim.keymap.set({ "n" }, "grn", ":IncRename ", { desc = "rename" })
vim.keymap.set(
	{ "n", "v" },
	"<leader>S",
	-- function() require('zaucy.lsp').dynamic_workspace_symbols({ theme = "ivy" }) end,
	function() require('multibuffer.plugins.symbols').multibuf_workspace_symbols("") end,
	{ desc = "Workspace symbols" }
)

vim.keymap.set(
	{ "n" },
	"grs",
	function()
		local word =  vim.fn.expand("<cword>")
		require('multibuffer.plugins.symbols').multibuf_workspace_symbols(word)
	end,
	{ desc = "Workspace symbols" }
)

vim.keymap.set(
	{ "n" },
	"gr/",
	function()
		local word =  vim.fn.expand("<cword>")
		require('telescope.builtin').live_grep({theme = "ivy"})
		vim.api.nvim_feedkeys(word, "n", false)
	end,
	{ desc = "Workspace symbols" }
)

-- quickfix
vim.keymap.set({ "n" }, "[q", "<cmd>cprevious<cr>", { desc = "prev qf item" })
vim.keymap.set({ "n" }, "]q", "<cmd>cnext<cr>", { desc = "next qf item" })

-- some script runners
vim.keymap.set({ "n", "v" }, "<C-S-B>", function() end, { desc = "" })

-- similar to alacritty escape
vim.keymap.set({ "t" }, "<C-S-Space>", "<C-\\><C-n>", { desc = "" })

-- arrow keys for window stuff
vim.keymap.set({ "n", "v" }, "<C-w><cr>", "<cmd>only<cr>", { desc = "Close other windows" })
vim.keymap.set({ "n", "v" }, "<C-w><C-left>", "<cmd>wincmd H<cr>", { desc = "Move window to the far left" })
vim.keymap.set({ "n", "v" }, "<C-w><C-down>", "<cmd>wincmd J<cr>", { desc = "Move window to the far bottom" })
vim.keymap.set({ "n", "v" }, "<C-w><C-up>", "<cmd>wincmd K<cr>", { desc = "Move window to the far top" })
vim.keymap.set({ "n", "v" }, "<C-w><C-right>", "<cmd>wincmd L<cr>", { desc = "Move window to the far right" })

-- tree sitter text object selections
local function select_textobject(a, b)
	return function()
		return require("nvim-treesitter-textobjects.select").select_textobject(a, b)
	end
end
vim.keymap.set({ "x", "o" }, "af",  select_textobject("@function.outer", "textobjects"))
vim.keymap.set({ "x", "o" }, "if",  select_textobject("@function.inner", "textobjects"))
vim.keymap.set({ "x", "o" }, "ac",  select_textobject("@class.outer", "textobjects"))
vim.keymap.set({ "x", "o" }, "ic",  select_textobject("@class.inner", "textobjects"))
vim.keymap.set({ "x", "o" }, "as",  select_textobject("@local.scope", "locals"))

vim.keymap.set({"n", "v"}, "<C-S-r>", "<cmd>mksession! ".. restart_session_file .. " | restart source " .. restart_session_file .. "<cr>")
vim.api.nvim_create_autocmd("SessionLoadPost", {
	callback = function(args)
		if vim.v.this_session == restart_session_file then
			vim.fn.delete(vim.v.this_session)
		else
			vim.notify("not session restart session file")
		end
	end,
})

-- chat
-- require("zaucy.chat").set_toggle_key("<C-S-CR>")
vim.keymap.set({"n", "v", "t"}, "<C-S-CR>", function() require("zaucy.chat").chat_toggle() end)
vim.keymap.set({"n", "v", "t"}, "<C-S-Up>", function() require("zaucy.chat").chat_set_fullscreen(true) end)
vim.keymap.set({"n", "v", "t"}, "<C-S-Down>", function() require("zaucy.chat").chat_set_fullscreen(false) end)
vim.keymap.set({"n", "v", "i"}, "<C-\\>f", "<cmd>GeminiFollow<cr>")
