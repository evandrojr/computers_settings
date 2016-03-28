#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

cmd="echo '$USER ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
sudo sh -c "$cmd"
sudo cat /etc/sudoers
