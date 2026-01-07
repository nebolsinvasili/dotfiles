#!/bin/sh

yay -S fastfetch --needed --noconfirm

stow -R -v -t ~/.config config
