#!/bin/bash
set -euo pipefail
set -x

DIR=$(realpath .)

# Global
ln -sfT $DIR/config/environment     /etc/environment
ln -sfT $DIR/config/pacman.conf     /etc/pacman.conf
ln -sfT $DIR/config/gitconfig       /etc/gitconfig
ln -sfT $DIR/config/sshd_config     /etc/ssh/sshd_config

ln -sfT $DIR/bin/l                  /usr/local/bin/l
ln -sfT $DIR/bin/t                  /usr/local/bin/t
ln -sfT $DIR/bin/c                  /usr/local/bin/c

# Tom
ln -sfT $DIR/config/helix           /home/tom/.config/helix
ln -sfT $DIR/config/gdb             /home/tom/.config/gdb
ln -sfT $DIR/config/alacritty.yml   /home/tom/.config/alacritty.yml
ln -sfT $DIR/prv/ssh-tom            /home/tom/.ssh

FF_HOME=/home/tom/.mozilla/firefox/*.default-release
if [ -d $FF_HOME ]; then
  mkdir -p $FF_HOME/chrome
  ln -sfT $DIR/config/firefox/userChrome.css $FF_HOME/chrome/userChrome.css
fi

# Root
ln -sfT $DIR/config/helix           /root/.config/helix
ln -sfT $DIR/config/gdb             /root/.config/gdb

echo Manual with pacman:      prv/pacman-packages.txt
echo Manual with GreasMonkey: config/firefox/js
echo Manual with Stylus:      config/firefox/css
