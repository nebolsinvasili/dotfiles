#!/usr/bin/env bash
set -euo pipefail

FONT_SIZES="8 10 12 14 16 18 24 32"


### ===== KEYMAP =====
# Получаем список keymap через systemd
keymaps=$(localectl list-keymaps)

# Интерактивный поиск
selected_keymaps=$(echo "$keymaps" | gum filter \
  --no-limit \
  --height 20 \
  --prompt "Выберите раскладки клавиатуры (Tab — несколько):")

if [ -z "$selected_keymaps" ]; then
  echo "Ошибка: раскладки не выбраны"
  exit 1
fi

# Основная раскладка (vconsole поддерживает только одну)
if [ "$(echo "$selected_keymaps" | wc -l)" -gt 1 ]; then
  primary_keymap=$(echo "$selected_keymaps" | gum choose \
    --header "Выберите основную раскладку (KEYMAP):")
else
  primary_keymap="$selected_keymaps"
fi


### ===== FONT =====
FONT_BASE="/usr/share/kbd/consolefonts"

fonts=$(find "$FONT_BASE" -type f \
  \( -name '*.psf.gz' -o -name '*.psfu.gz' \) \
  -printf "%f\n")

selected_font=$(echo "$fonts" | gum filter \
  --height 20 \
  --prompt "Выберите консольный шрифт:")

if [ -z "$selected_font" ]; then
  echo "Ошибка: шрифт не выбран"
  exit 1
fi

font_size=$(echo "$FONT_SIZES" | tr ' ' '\n' | gum choose \
  --header "Выберите желаемый размер шрифта (если доступен):")


### ===== ПРИМЕНЕНИЕ =====
cat > /etc/vconsole.conf <<EOF
KEYMAP=$primary_keymap
FONT=$selected_font
EOF

echo
echo "✔ Конфигурация консоли применена"
echo "  KEYMAP: $primary_keymap"
echo "  FONT:   $selected_font"
