local function process_prompt_config(prompt)
	return vim.tbl_deep_extend('error', prompt, {
		opts = {
			index = -1,
		}
	})
end

local prompt_configs = vim.tbl_map(process_prompt_config, {
	require("zaucy.llm.prompts.gimme_options"),
})

local prompt_config_table = {}

for i, prompt_config in ipairs(prompt_configs) do
	prompt_config.opts.index = i
	prompt_config_table[prompt_config.name] = prompt_config
end

return prompt_config_table
