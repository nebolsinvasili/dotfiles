#!/bin/sh

yay -S git --needed --noconfirm

stow -R -v -t ~/ config
