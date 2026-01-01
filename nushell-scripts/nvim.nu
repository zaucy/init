let nvim = if 'LOCALAPPDATA' in $env {
	({
		data_path: ($env.LOCALAPPDATA + "\\nvim-data"),
		config_path: ($env.LOCALAPPDATA + "\\nvim"),
	})
} else {
	({
		data_path: '~/.local/share/nvim',
		config_path: '~/.config/nvim',
	})
}

