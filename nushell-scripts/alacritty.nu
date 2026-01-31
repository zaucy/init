let alacritty = if 'APPDATA' in $env {
	({
		config_path: ($env.APPDATA + "\\alacritty\\alacritty.toml"),
	})
} else {
	({
		config_path: null,
	})
};
