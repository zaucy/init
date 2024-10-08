source ~/projects/zaucy/init/nushell-scripts/helix.nu
source ~/projects/zaucy/init/nushell-scripts/file.nu
source ~/projects/zaucy/init/nushell-scripts/nvim.nu

symlink ./nvim-config-minimal/ $nvim.config_path;

let local_wezterm_config_path = ([$env.FILE_PWD, "wezterm", "default.lua"] | path join);
let wezterm_config_path = (["~", ".config", "wezterm", "wezterm.lua"] | path join | path expand);
symlink $local_wezterm_config_path $wezterm_config_path --force;

return;
