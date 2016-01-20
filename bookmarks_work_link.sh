#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

link_hard $SRC/chrome/Bookmarks_work ~/.config/google-chrome/Default/Bookmarks
