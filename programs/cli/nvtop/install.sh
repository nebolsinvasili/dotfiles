#!/bin/sh

yay -S nvtop --noconfirm

stow -R -v -t ~/.config config
