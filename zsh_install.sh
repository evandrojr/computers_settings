#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"


say "Linking .zsh_standards and .zsh_aliases"

link $SRC/zsh/.zsh_standards ~/.zsh_standards
link $SRC/zsh/.zsh_aliases ~/.zsh_aliases
say "Creating user bin dir if not exists"
run mkdir -pv ~/bin
link $SRC/zsh/zsh_add_custom_settings.sh ~/bin/zsh_add_custom_settings.sh
say "After updating oh-my-zsh remember to run zsh_add_custom_settings.sh"
