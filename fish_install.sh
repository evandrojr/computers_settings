#!/bin/sh
sudo apt-get install fish
chsh -s `which fish`
cp fish/config.fish ~/.config/fish/config.fish -vv
