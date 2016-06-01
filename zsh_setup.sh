#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

say "Installing zsh"
run sudo apt-get install zsh

say "Setting zsh as default"
run chsh -s $(which zsh)

run rm -rf ~/.oh-my-zsh

say "Installing oh-my-zsh"
run sudo apt-get install curl

say "Linking .zsh_standards and .zsh_aliases"

link $SRC/zsh/.zsh_standards ~/.zsh_standards
link $SRC/zsh/.zsh_aliases ~/.zsh_aliases
say "Creating user bin dir if not exists"
run mkdir -pv ~/bin
run rm ~/bin/zsh_add_custom_settings.sh
link $SRC/zsh/zsh_add_custom_settings.sh ~/bin/zsh_add_custom_settings.sh

say "At the end run zsh_add_custom_settings.sh manually, otherwise no aliases and so!!!"

say "Installing oh-my-zsh"
run sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
