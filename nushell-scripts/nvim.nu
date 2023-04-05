let nvim = if 'LOCALAPPDATA' in $env {
	({
		data_path: ($env.LOCALAPPDATA + "\\nvim-data"),
		config_path: ($env.LOCALAPPDATA + "\\nvim"),
	})
} else {
	({
		data_path: '~/.config/nvim-data',
		config_path: '~/.local/share/nvim',
	})
}

