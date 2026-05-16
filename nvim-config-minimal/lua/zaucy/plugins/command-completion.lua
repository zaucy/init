local slow_completion_prefix = {
	"'",
	"!", -- shell autocomplete is really slow on Windows
	"'", -- autocompelte on selections just doesn't work very well
	"%",
	"Q", -- I prefix commands I don't type manually with this so that my cmdline autocomplete can be snappy and no flickering occurs
	"te",
	"ter",
	"term",
	"termi",
	"termin",
	"termina",
	"terminal",
	"terminal ",
	"g/",
	"Norm",
	"Preview",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
}

require("command-completion").setup({
	filter_completion = function(input)
		if input == "" then
			return false
		end

		for _, prefix in ipairs(slow_completion_prefix) do
			if vim.startswith(input, prefix) then
				return false
			end
		end
		return true
	end,
})
