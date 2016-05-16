#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

run git clone https://github.com/rbenv/rbenv.git ~/.rbenv
run cd ~/.rbenv && src/configure && make -C src
run echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
run echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
run git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
run git clone -- https://github.com/carsomyr/rbenv-bundler.git  ~/.rbenv/plugins/bundler
say "Turning on auto bundle exec"
run rbenv bundler on
run rbenv install -l
say "Now rbenv install your favourite version"
