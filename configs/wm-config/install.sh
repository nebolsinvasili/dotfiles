yay -S xorg xorg-xinit xorg-server xorg-xrandr xorg-xrdb --needed --noconfirm
yay -S bspwm sxhkd --needed --noconfirm
yay -S polybar picom rofi dunst feh --needed --noconfirm
yay -S scrot nemo cups network-manager-applet --needed --noconfirm

stow -R -v -t ~/.config config
# mkdir -p ~/.screenlayout && stow -R -v -t ~/.screenlayout .screenlayout

sudo chmod +x ~/.config/bspwm/bspwmrc
sudo chmod +x ~/.config/bspwm/config/sxhkdrc
# sudo chmod +x ~/.screenlayout/display.sh

cat <<EOF >~/.xinitrc
exec sxhkd -c ~/.config/bspwm/config/sxhkdrc &  
exec bspwm -c ~/.config/bspwm/bspwmrc
EOF

# $HOME/.screenlayout/display.sh
# [[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources
