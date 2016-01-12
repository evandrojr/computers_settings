#!/bin/sh
set -e

say() {
  msg="$@"
  if [ -t 1 ]; then
    printf "\033[1;34;49m%s\033[m\n" "$msg"
  else
    echo "$msg"
  fi
}

complain() {
  msg="$@"
  if [ -t 1 ]; then
    printf "\033[1;31;49m%s\033[m\n" "$msg"
  else
    echo "$msg"
  fi
}

run() {
  say "\$ $@"
  local rc=0
  "$@" || rc=$?
  if [ $rc -ne 0 ]; then
    complain "E: The command \"$@\" failed with status code $status, we cannot proceed."
    exit 1
  fi
}

gem_install() {
  if [ -w "$(ruby -rubygems -e 'puts Gem.dir')" ]; then
    run gem install --no-ri --no-rdoc $@
  else
    run gem install --user-install --no-ri --no-rdoc $@
  fi
}

################## BEGINNING ####################################3

say "This scripts checks if you are in the correct directory in order to run properly."
say "Checking..."
if [ -f computer_settings_dir ]
  then
    say "computer_settings_dir exists. Lucky guy!"
  else
    complain "computer_settings_dir NOT exists you are in the wrong directory, go to the project directory"
    exit 1

fi
say "Linking .xsession"
run rm -fv ~/.xsession
run ln -sv `pwd`/x/.xsession ~/.xsession
