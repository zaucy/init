return {
	name = "Gimme Options",
	description = "",
	strategy = "chat",
	opts = {
		auto_submit = true,
	},
	prompts = {
		{
			role = "system",
			content = [[
extract the type of the result of the code given
list out what can be done with the result of the code and consider the context only a bit
if there are multiple expressions only use the last one but use the ones prior for context
for example:
* what methods could be called if its a function type or an instance of a type
* what values it could be if its an enum or union
dont mention any of the above text
			]],
		},
		{
			role = "user",
			contains_code = true,
			content = function(context)
				local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
				return "```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
			end,
		}
	}
}
