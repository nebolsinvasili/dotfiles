#!/usr/bin/env bash
set -euo pipefail


# ==== Ввод имени хоста через gum ====
hostname=$(gum input \
  --prompt "Введите имя хоста:" \
  --placeholder "archlinux")

# Значение по умолчанию
[ -z "$hostname" ] && hostname="archlinux"


### ==== Валидация имени хоста (RFC 952 / 1123) ====
if ! [[ "$hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$ ]]; then
  echo "Ошибка: недопустимое имя хоста"
  exit 1
fi


### ==== Применение имени хоста ====
# /etc/hostname
echo "$hostname" > /etc/hostname

# /etc/hosts
cat > /etc/hosts <<EOF
127.0.0.1      localhost
::1            localhost
127.0.1.1      $hostname.localdomain $hostname
EOF

echo "✔ Имя хоста установлено: $hostname"
