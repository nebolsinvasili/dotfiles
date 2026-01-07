#!/bin/sh
set -e # Остановиться при ошибке

# === Установка GTK ===
echo "[+] Устанавливаю GTK..."
#yay -S --needed --noconfirm gtk gtk2 gtk3 gtk4
#yay -S --needed --noconfirm nerd-fonts noto-fonts-emoji ttf-noto-emoji-monochrome
#yay -S --needed --noconfirm whitesur-gtk-theme whitesur-icon-theme qogir-cursor-theme

stow -R -v -t ~ config

# sudo sh -c 'cat << EOF > /usr/share/icons/default/index.theme
# [Icon Theme]
# Inherits=Qogir-cursors
# EOF'

#git clone https://github.com/zhichaoh/catppuccin-wallpapers.git ~/.config/wallpapers

echo "[✓] Установка завершена."
