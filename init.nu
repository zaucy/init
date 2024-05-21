source ~/projects/zaucy/init/nushell-scripts/helix.nu
source ~/projects/zaucy/init/nushell-scripts/file.nu
source ~/projects/zaucy/init/nushell-scripts/nvim.nu

glob helix/**/*.toml | each {|toml_path| 
  let local_path = ($toml_path | path relative-to ('helix' | path expand));
  let config_file_path = ([$helix.config_path, $local_path] | path join);
  symlink (['helix', $local_path] | path join) $config_file_path --force;
};

symlink ./nvim-config/ $nvim.config_path;

let local_wezterm_config_path = ([$env.FILE_PWD, "wezterm", "default.lua"] | path join);
let wezterm_config_path = (["~", ".config", "wezterm", "wezterm.lua"] | path join | path expand);
symlink $local_wezterm_config_path $wezterm_config_path --force;

return;
