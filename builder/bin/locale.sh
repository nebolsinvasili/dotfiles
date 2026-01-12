#!/usr/bin/env bash
set -euo pipefail


### ===== ПОЛУЧЕНИЕ ДОСТУПНЫХ ЛОКАЛЕЙ =====
locales=$(grep -E '^[#]?[a-zA-Z0-9_@.-]+ UTF-8' /etc/locale.gen \
  | awk '{print $1}' \
  | sed 's/^#//')


### ===== ВЫБОР ЛОКАЛЕЙ =====
selected_locales=$(echo "$locales" | gum filter \
  --no-limit \
  --height 20 \
  --prompt "Выберите локали для активации (Tab — несколько):")

if [ -z "$selected_locales" ]; then
  echo "Ошибка: локали не выбраны"
  exit 1
fi


### ===== РАСКОММЕНТИРОВАНИЕ locale.gen =====
while IFS= read -r locale; do
  sed -i "s/^#\(${locale}[[:space:]]\+UTF-8\)/\1/" /etc/locale.gen
done <<< "$selected_locales"


### ===== ГЕНЕРАЦИЯ ЛОКАЛЕЙ =====
locale-gen


### ===== ВЫБОР LANG =====
if [ "$(echo "$selected_locales" | wc -l)" -gt 1 ]; then
  lang_locale=$(echo "$selected_locales" | gum choose \
    --header "Выберите локаль для LANG:")
else
  lang_locale="$selected_locales"
fi


### ===== УСТАНОВКА LANG =====
echo "LANG=$lang_locale" > /etc/locale.conf


### ===== ВЫВОД =====
echo
echo "✔ Локали сгенерированы"
echo "✔ LANG установлен: $lang_locale"
