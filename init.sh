#!/bin/sh

set -e

InitDir="$HOME/projects/zaucy/init"

if [ "$InitDir" != "$(pwd)" ]; then
  mkdir -p "$InitDir"
  echo Changing directory: $InitDir
  cd $InitDir
fi

if [ -z "$(which cargo)" ]; then
  curl https://sh.rustup.rs -sSf | sh
fi

if [ -z "$(which nu)" ]; then
  cargo install nu --features=extra
fi
