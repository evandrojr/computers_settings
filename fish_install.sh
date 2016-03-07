#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

# run sudo apt-get install fish
# Installs a more recent version
run sudo dpkg -i $SRC/fish/install/fish_2.2.0-1-trusty_amd64.deb
run sudo chsh -s `which fish` $USER
run mkdir -p ~/.config/fish
run rm ~/.config/fish/config.fish -fv
run rm ~/.config/fish/functions -rfv
run ln -sv $SRC/fish/.config/fish/config.fish ~/.config/fish/config.fish
run ln -sv $SRC/fish/.config/fish/functions ~/.config/fish/functions

# Install bass to be used with nvm
run cd $SRC/fish/install/bass/
run make install
