#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

link $SRC/ruby/.irbrc ~/.irbrc
link $SRC/ruby/.pryrc ~/.pryrc
say "Creating user bin dir if not exists"
run mkdir -pv ~/bin
link $SRC/ruby/remove_breakpoints.rb ~/bin/remove_breakpoints.rb
link $SRC/noosfero/add_noosfero_administrator.rb ~/bin/add_noosfero_administrator.rb
run rm -f ~/bin/noosfero
# Can be improved, no need more for a ~/bin/noosfero can use $SRC now
link $SRC/noosfero ~/bin/noosfero
gem_install "jazz_fingers"
say "Always remember to run 'add_gemfile_for_debbuging' to enable debugging"
