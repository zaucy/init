return {
	{
		"jake-stewart/multicursor.nvim",
		event = "VeryLazy",
		config = function()
			local mc = require("multicursor-nvim")
			mc.setup()

			vim.api.nvim_set_hl(0, "MultiCursorCursor", { reverse = true, fg = "#73daca" })

			vim.keymap.set({ "n", "v" }, ",", mc.clearCursors)
			vim.keymap.set({ "n", "v" }, "<A-->", mc.deleteCursor)
			vim.keymap.set({ "n", "v" }, "&", mc.alignCursors)

			vim.keymap.set({ "n", "v" }, "gM", function()
				require("which-key").show({ keys = "gm", loop = true })
			end, { desc = "Multicursor Hydra" })

			vim.keymap.set({ "n", "v" }, "gmx", mc.deleteCursor, { desc = "Delete cursor" })
			vim.keymap.set({ "n", "v" }, "gml", mc.nextCursor, { desc = "Next cursor" })
			vim.keymap.set({ "n", "v" }, "gmh", mc.prevCursor, { desc = "Prev cursor" })
			vim.keymap.set({ "n", "v" }, "gm<right>", mc.nextCursor, { desc = "Next cursor" })
			vim.keymap.set({ "n", "v" }, "gm<left>", mc.prevCursor, { desc = "Prev cursor" })
			vim.keymap.set({ "n", "v" }, "gm<c-l>", mc.lastCursor, { desc = "Last cursor" })
			vim.keymap.set({ "n", "v" }, "gm<c-h>", mc.firstCursor, { desc = "First cursor" })
			vim.keymap.set({ "n", "v" }, "gm<c-right>", mc.lastCursor, { desc = "Last cursor" })
			vim.keymap.set({ "n", "v" }, "gm<c-left>", mc.firstCursor, { desc = "First cursor" })

			vim.keymap.set({ "n", "v" }, "gm,", mc.clearCursors, { desc = "Clear Cursors" })
			vim.keymap.set({ "n", "v" }, "gm<A-->", mc.deleteCursor, { desc = "Delete Cursor" })
			vim.keymap.set({ "n", "v" }, "gm&", mc.alignCursors, { desc = "Align cursors" })
			vim.keymap.set({ "n", "v" }, "gmm", mc.matchAllAddCursors, { desc = "Match all add cursor" })
			vim.keymap.set({ "n", "v" }, "gm/", mc.searchAllAddCursors, { desc = "Search all add cursors" })
			vim.keymap.set({ "n", "v" }, "gmn", function()
				mc.matchAddCursor(1)
			end, { desc = "Match add cursor next" })
			vim.keymap.set({ "n", "v" }, "gmN", function()
				mc.matchAddCursor(-1)
			end, { desc = "Match add cursor prev" })
			vim.keymap.set({ "n", "v" }, "gm<up>", function()
				mc.lineAddCursor(-1)
			end, { desc = "Add cursor prev line" })
			vim.keymap.set({ "n", "v" }, "gmk", function()
				mc.lineAddCursor(-1)
			end, { desc = "Add cursor prev line" })
			vim.keymap.set({ "n", "v" }, "gm<down>", function()
				mc.lineAddCursor(1)
			end, { desc = "Add cursor next line" })
			vim.keymap.set({ "n", "v" }, "gmj", function()
				mc.lineAddCursor(1)
			end, { desc = "Add cursor next line" })
			vim.keymap.set("v", "gm<A-Up>", function()
				mc.transposeCursors(1)
			end, { desc = "Transpose cursor selection next" })
			vim.keymap.set("v", "gm<A-Down>", function()
				mc.transposeCursors(-1)
			end, { desc = "Transpose cursor selection prev" })

			-- operators
			vim.keymap.set("n", "gmo", function()
				mc.operator({ visual = false })
			end, { desc = "Mulicursor operator" })
			vim.keymap.set("v", "gmo", function()
				mc.operator({ visual = true })
			end, { desc = "Mulicursor operator" })

			-- motions
			vim.keymap.set("n", "gm%", function()
				mc.addCursor("%")
			end, { desc = "Add cursor to match" })
			vim.keymap.set("n", "gmw", function()
				mc.addCursor("w")
			end, { desc = "Add cursor next word" })
			vim.keymap.set("n", "gmW", function()
				mc.addCursor("W")
			end, { desc = "Add cursor next WORD" })
			vim.keymap.set("n", "gmb", function()
				mc.addCursor("b")
			end, { desc = "Add cursor prev word" })
			vim.keymap.set("n", "gmB", function()
				mc.addCursor("B")
			end, { desc = "Add cursor prev WORD" })
			vim.keymap.set("n", "gme", function()
				mc.addCursor("e")
			end, { desc = "Add cursor end of word" })
			vim.keymap.set("n", "gmE", function()
				mc.addCursor("E")
			end, { desc = "Add cursor end of WORD" })
			vim.keymap.set("n", "gm$", function()
				mc.addCursor("$")
			end, { desc = "Add cursor end of line" })
			vim.keymap.set("n", "gm0", function()
				mc.addCursor("0")
			end, { desc = "Add cursor start of line" })

			-- char motions
			vim.keymap.set("n", "gmf", function()
				mc.addCursor("f" .. vim.fn.nr2char(vim.fn.getchar()))
			end, { desc = "Add cursor at next char" })
			vim.keymap.set("n", "gmF", function()
				mc.addCursor("F" .. vim.fn.nr2char(vim.fn.getchar()))
			end, { desc = "Add cursor at prev char" })
			vim.keymap.set("n", "gmt", function()
				mc.addCursor("t" .. vim.fn.nr2char(vim.fn.getchar()))
			end, { desc = "Add cursor at before next char" })
			vim.keymap.set("n", "gmT", function()
				mc.addCursor("T" .. vim.fn.nr2char(vim.fn.getchar()))
			end, { desc = "Add cursor at before prev char" })
		end,
	},
	{
		"zaucy/mcos.nvim",
		dependencies = {
			"jake-stewart/multicursor.nvim",
		},
		config = function()
			local mcos = require("mcos")
			mcos.setup({})
			vim.keymap.set({ "n", "v" }, "gms", mcos.opkeymapfunc, { expr = true })
			vim.keymap.set({ "n" }, "gmss", mcos.bufkeymapfunc)
		end,
	},
}
