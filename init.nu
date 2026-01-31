source ~/projects/zaucy/init/nushell-scripts/helix.nu
source ~/projects/zaucy/init/nushell-scripts/file.nu
source ~/projects/zaucy/init/nushell-scripts/nvim.nu
source ~/projects/zaucy/init/nushell-scripts/alacritty.nu

symlink --force ./nvim-config-minimal/ $nvim.config_path;
symlink --force "./alacritty/default.toml" $alacritty.config_path;
