local keys = {}

for i = 1, 9 do
	table.insert(keys, {
		tostring(i),
		function()
			local resession = require("resession")
			local name = "rts-" .. tostring(i)
			local current_name = resession.get_current()
			if current_name ~= name then
				if current_name then
					resession.save(current_name, {
						attach = false,
						notify = false,
					})
				end
				resession.load(name, {
					attach = true,
					silence_errors = true,
				})
			end
		end
	})

	table.insert(keys, {
		"<C-" .. tostring(i) .. ">",
		function()
			local resession = require("resession")
			resession.save("rts-" .. tostring(i), {
				attach = true,
				notify = false,
			})
		end
	})
end

return {
	"stevearc/resession.nvim",
	keys = keys,
	opts = {},
}
