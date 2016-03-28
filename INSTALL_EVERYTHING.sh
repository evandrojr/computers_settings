#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

# run $SRC/fish_install.sh || true
run $SRC/ruby_coolness_install.sh || true
# run $SRC/xflux_install.rb || true
run $SRC/x_improvements.sh || true
run $SRC/atom_setup.sh || true
