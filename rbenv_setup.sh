#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"
RUBY_VERSION="2.3.0"

run rm -rf ~/.rbenv
run git clone https://github.com/rbenv/rbenv.git ~/.rbenv
run cd ~/.rbenv && src/configure && make -C src
run echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
run echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
run git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
run rbenv install $RUBY_VERSION
run rbenv rehash
rbenv global $RUBY_VERSION
gem install bundler
# run git clone -- https://github.com/carsomyr/rbenv-bundler.git  ~/.rbenv/plugins/bundler
# say "Turning on auto bundle exec"
# run rbenv bundler on
run rbenv install -l
say "Now rbenv install your favourite version"
