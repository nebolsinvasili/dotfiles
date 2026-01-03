#!/bin/sh

#  Install the virtualbox package. You will also need to choose a package to provide host modules:
#
#   for the linux kernel, choose virtualbox-host-modules-arch,
#   for the linux-lts kernel, choose virtualbox-host-modules-lts,
#   for any other kernel, choose virtualbox-host-dkms.

yay -S virtualbox --noconfirm
