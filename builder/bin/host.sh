#!/bin/bash

# Ввод имени хоста с Gum, по умолчанию archlinux
hostname=$(gum input \
  --prompt "Введите имя хоста:" \
  --placeholder "archlinux")

# Проверка на пустой ввод (на всякий случай)
if [ -z "$hostname" ]; then
  hostname="archlinux"
fi

# Записываем имя хоста в /etc/hostname
echo "$hostname" | sudo tee /etc/hostname >/dev/null

# Редактируем /etc/hosts
sudo tee /etc/hosts >/dev/null <<EOF
127.0.0.1      localhost
::1            localhost
127.0.1.1      $hostname
EOF

# Подтверждение
echo "Имя хоста установлено: $(cat /etc/hostname)"
echo "Содержимое /etc/hosts:"
cat /etc/hosts
