#!/usr/bin/env bash
set -euo pipefail


### ===== ПОЛУЧЕНИЕ СПИСКА ЧАСОВЫХ ПОЯСОВ =====
ZONEINFO="/usr/share/zoneinfo"

timezones=$(find "$ZONEINFO" -type f \
  ! -path "$ZONEINFO/posix/*" \
  ! -path "$ZONEINFO/right/*" \
  ! -path "$ZONEINFO/Etc/*" \
  -printf "%P\n")


### ===== ИНТЕРАКТИВНЫЙ ВЫБОР =====
selected_timezone=$(echo "$timezones" | gum filter \
  --height 20 \
  --prompt "Начните вводить название часового пояса:")

if [ -z "$selected_timezone" ]; then
  echo "Ошибка: часовой пояс не выбран"
  exit 1
fi


### ===== ВАЛИДАЦИЯ =====
if [ ! -f "$ZONEINFO/$selected_timezone" ]; then
  echo "Ошибка: файл часового пояса не существует"
  exit 1
fi


### ===== ПРИМЕНЕНИЕ =====
ln -sf "$ZONEINFO/$selected_timezone" /etc/localtime

# Генерация аппаратных часов (UTC по умолчанию для Arch)
hwclock --systohc


### ===== ВЫВОД =====
echo
echo "✔ Часовой пояс установлен: $selected_timezone"
