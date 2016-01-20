#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

run sudo apt-get install fish
run chsh -s `which fish`
run mkdir -p ~/.config/fish
run rm ~/.config/fish/config.fish -fv
run rm ~/.config/fish/functions -rfv
run ln -sv $SRC/fish/.config/fish/config.fish ~/.config/fish/config.fish
run ln -sv $SRC/fish/.config/fish/functions ~/.config/fish/functions
