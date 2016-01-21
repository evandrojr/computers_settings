#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

link $SRC/ssh/config ~/.ssh/config
