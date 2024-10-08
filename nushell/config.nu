# use ~/projects/zaucy/init/nushell-scripts/nu_scripts/modules/fnm/fnm.nu

$env.config = {
  show_banner: false,
}

source ~/.zoxide.nu
source ~/projects/zaucy/init/nushell-scripts/file.nu
source ~/projects/zaucy/init/stream/scripts/chat-popout.nu
source ~/projects/zaucy/init/nushell-scripts/nvim.nu
source ~/projects/zaucy/init/nushell-scripts/helix.nu
source ~/projects/zaucy/init/nushell-scripts/git.nu
source ~/projects/zaucy/init/nushell-scripts/wsl.nu
source ~/projects/zaucy/init/nushell-scripts/zoxide.nu
source ~/projects/zaucy/init/nushell-scripts/ecsact.nu
source ~/projects/zaucy/init/nushell-scripts/bazel.nu
source ~/projects/zaucy/init/nushell-scripts/ocaml.nu

# Completions
source ~/projects/zaucy/init/nushell-scripts/nu_scripts/custom-completions/git/git-completions.nu
source ~/projects/zaucy/init/nushell-scripts/nu_scripts/custom-completions/auto-generate/completions/cargo.nu
