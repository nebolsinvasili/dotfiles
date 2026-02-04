#!/bin/sh

# Определяем путь к папке, где лежит этот скрипт
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo $SCRIPT_DIR

yay -S kitty --needed --noconfirm

# -d указывает, где искать папку 'config'
# -t указывает, куда ставить симлинки
stow -R -v -d "$SCRIPT_DIR" -t ~/.config config
