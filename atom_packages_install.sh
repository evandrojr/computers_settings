#!/bin/sh

sudo add-apt-repository ppa:webupd8team/atom
sudo apt-get update
sudo apt-get install atom

#apm install language-ruby
apm install ruby-test-switcher || true
apm install tabs-to-spaces || true
apm install atom-ctags || true
#apm install autocomplete-plus || true
apm install ruby-block || true
apm install atom-rails  || true
apm install file-icons || true
apm install git-plus || true
apm install remote-edit || true
apm install ruby-test || true
apm install execute-as-ruby || true
apm install editorconfig || true
apm install file-watcher || true
# Cool but too dangereous :( because of this atom Bug
# https://github.com/lwblackledge/file-watcher/issues/4
#apm install saveallthetime || true
