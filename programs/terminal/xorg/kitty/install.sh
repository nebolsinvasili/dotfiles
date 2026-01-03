#!/bin/sh

yay -S kitty --needed --noconfirm

stow -R -v -t ~/.config config
