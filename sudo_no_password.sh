#!/bin/sh
cmd="echo '$USER ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
sudo sh -c "$cmd"
sudo cat /etc/sudoers
