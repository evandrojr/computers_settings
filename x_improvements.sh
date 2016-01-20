#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/core.sh"

run sudo rm -fv /etc/X11/Xsession.d/40x11-common_xsessionrc
say "Linking fixed /etc/X11/Xsession.d/40x11-common_xsessionrc"
run sudo ln -sv $SRC/x/40x11-common_xsessionrc /etc/X11/Xsession.d/40x11-common_xsessionrc

run sudo rm -fv ~/.xsessionrc
link -sv $SRC/x/.xsessionrc ~/.xsessionrc
