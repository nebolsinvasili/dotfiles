#!/bin/bash

while true; do
  clear

  # Информация о дисках
  lsblk -d
  echo

  # Список дисков
  disks=$(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}')

  selected_disk=$(echo "$disks" | gum choose --height 10 --header "Выберите диск:")

  [ -z "$selected_disk" ] && exit 1

  clear
  echo "Выбран диск: $selected_disk"
  echo

  # Разделы выбранного диска
  lsblk "$selected_disk"
  echo

  action=$(
    gum choose \
      "РАЗМЕТИТЬ" \
      "МОНТИРОВАТЬ" \
      "НАЗАД" \
      --header "Что сделать с $selected_disk?"
  )

  case "$action" in
  "РАЗМЕТИТЬ")
    confirm=$(
      gum choose \
        "ДА" \
        "НЕТ" \
        --header "ВНИМАНИЕ: все данные на $selected_disk будут утеряны. Продолжить?"
    )

    if [ "$confirm" = "ДА" ]; then
      cfdisk "$selected_disk"
    fi
    ;;
  "МОНТИРОВАТЬ")
    echo "Монтирование (пока не реализовано)"
    read -rp "Нажмите Enter для возврата..."
    ;;
  "НАЗАД")
    continue
    ;;
  esac
done
