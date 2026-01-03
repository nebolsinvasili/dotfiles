#!/bin/sh

yay -S htop --noconfirm

stow -R -v -t ~/.config config
