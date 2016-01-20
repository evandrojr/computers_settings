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

link() {
  run rm -fv $2
  say "Linking $1 to $2"
  run ln -sv $1 $2
}

link_hard() {
  run rm -fv $2
  say "Linking $1 to $2"
  run ln -v $1 $2
}
