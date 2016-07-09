#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"
NODE_VERSION = "6.3.0"

sudo apt-get install curl
run curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash

run nvm install $NODE_VERSION

say "Done!"
