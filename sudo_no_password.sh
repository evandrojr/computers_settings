#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

cmd="h"
sudo sh -c "$cmd"
sudo cat /etc/sudoers
