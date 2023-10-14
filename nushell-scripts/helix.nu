let helix = if 'APPDATA' in $env {
	({
		config_path: ($env.APPDATA + "\\helix"),
	})
} else {
	({
		config_path: '~/.config/helix',
	})
}
