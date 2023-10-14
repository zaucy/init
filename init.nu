source ~/projects/zaucy/init/nushell-scripts/helix.nu
source ~/projects/zaucy/init/nushell-scripts/file.nu

glob helix/**/*.toml | each {|toml_path| 
  let local_path = ($toml_path | path relative-to ('helix' | path expand));
  let config_file_path = ([$helix.config_path, $local_path] | path join);
  symlink (['helix', $local_path] | path join) $config_file_path --force;
};

return;
