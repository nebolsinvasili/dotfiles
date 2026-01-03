#!/bin/bash

# Получаем все часовые пояса, исключая служебные
timezones=$(find /usr/share/zoneinfo -type f \
  ! -path "/usr/share/zoneinfo/posix/*" \
  ! -path "/usr/share/zoneinfo/right/*" \
  ! -path "/usr/share/zoneinfo/Etc/*" \
  -printf "%P\n")

# Выбираем через gum filter
selected_timezone=$(echo "$timezones" | gum filter --height 20 --prompt "Начните вводить название зоны: ")

echo "Вы выбрали: $selected_timezone"

# Применение системного часового пояса (необязательно)
# sudo timedatectl set-timezone "$selected_timezone"
# hwclock --systohc
