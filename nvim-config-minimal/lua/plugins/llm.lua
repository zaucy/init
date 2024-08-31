return {
	{
		"David-Kunz/gen.nvim",
		-- dir = "~/projects/gen.nvim",
		opts = {
			model = "llama3.1",
			quit_map = "q", -- set keymap for close the response window
			retry_map = "<c-r>", -- set keymap to re-send the current prompt
			accept_map = "<c-cr>", -- set keymap to replace the previous selection with the last result
			host = "localhost", -- The host running the Ollama service.
			port = "11434", -- The port on which the Ollama service is listening.
			display_mode = "float", -- The display mode. Can be "float" or "split" or "horizontal-split".
			show_prompt = false, -- Shows the prompt submitted to Ollama.
			show_model = false, -- Displays which model you are using at the beginning of your chat session.
			no_auto_close = false, -- Never closes the window automatically.
			hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
			init = function(options)
				vim.notify("Starting ollama")
				vim.uv.spawn("ollama", {
					args = { "serve" },
				}, function(code, _)
					vim.notify("Ollama exited with code " .. code, vim.log.levels.ERROR)
				end)
			end,
			-- Function to initialize Ollama
			command = function(options)
				return "curl --silent --no-buffer -X POST http://" ..
					options.host .. ":" .. options.port .. "/api/chat -d $body"
			end,
			-- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
			-- This can also be a command string.
			-- The executed command must return a JSON object with { response, context }
			-- (context property is optional).
			-- list_models = '<omitted lua function>', -- Retrieves a list of mo
			debug = true,
		},
	}
}
