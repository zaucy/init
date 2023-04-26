#!/bin/bash

set -e

InitDir="$HOME/projects/zaucy/init"

if [ "$InitDir" != "$(pwd)" ]; then
  mkdir -p "$InitDir"
  echo Changing directory: $InitDir
  cd $InitDir
fi

if [ -z "$(which git)" ]; then
  sudo apt install git -y
fi

if [ ! -d ".git" ]; then
  git clone --recurse-submodules https://github.com/zaucy/init.git .
else
  git pull
fi

mkdir -p $HOME/.config/nvim
cp ./nvim-config/* $HOME/.config/nvim --force --recursive

mkdir -p $HOME/.config/nushell
cp ./nushell/* $HOME/.config/nushell --force --recursive

if [ -z "$(which gh)" ]; then
  type -p curl >/dev/null || sudo apt install curl -y
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
fi

if [ -z "$(which bazel)" ]; then
  gh release download -R bazelbuild/bazelisk -p 'bazelisk-linux-amd64' -O "$HOME/.local/bin/bazel" --clobber
  chmod +x "$HOME/.local/bin/bazel"
fi

if [ -z "$(which nvim)" ]; then
  sudo add-apt-repository ppa:neovim-ppa/unstable -y
  sudo apt-get update -y
  sudo apt-get install neovim -y
fi

touch ~/.zoxide.nu
touch ~/.fnm/fnm_config.nu
touch ~/.fnm/fnm_env.nu

if [ -z "$(which cargo)" ]; then
  curl https://sh.rustup.rs -sSf | sh
fi

if [ -z "$(which nu)" ]; then
  cargo install nu --features=extra
fi

if [ -z "$(which zoxide)" ]; then
  cargo install zoxide
fi

