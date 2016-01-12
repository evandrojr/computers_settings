#!/bin/sh
u=$USER
sudo sh -c 'echo "$u ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
sudo cat /etc/sudoers
