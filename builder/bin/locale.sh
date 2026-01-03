#!/bin/bash

# Берём все локали из /etc/locale.gen и убираем #
locales=$(grep -E '^[#]?[a-zA-Z0-9_@.-]+ UTF-8' /etc/locale.gen | awk '{print $1}' | sed 's/^#//')

# Выбор локалей через gum filter (можно выбрать несколько)
selected_locales=$(echo "$locales" | gum filter --height 20 --prompt "Выберите локали для активации (Tab для множественного выбора, Enter для выбора): " --no-limit)

if [ -z "$selected_locales" ]; then
  echo "Локали не выбраны."
  exit 1
fi

# Генерируем локали
# while IFS= read -r locale; do
#     sudo sed -i "s/^#\s*\($locale\)/\1/" /etc/locale.gen
# done <<< "$selected_locales"
# sudo locale-gen

# Определяем системную LANG
if [ $(echo "$selected_locales" | wc -l) -gt 1 ]; then
  # Если выбрано несколько локалей — просим выбрать одну для LANG
  lang_locale=$(echo "$selected_locales" | gum choose --header "Выберите локаль для переменной LANG:")
else
  # Если выбрана одна локаль — используем её
  lang_locale="$selected_locales"
fi

# Устанавливаем системную LANG
# echo "LANG=$lang_locale" | sudo tee /etc/locale.conf > /dev/null
# export LANG="$lang_locale"

echo "Системная LANG установлена: $LANG"
