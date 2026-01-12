#!/usr/bin/env bash
set -euo pipefail


### ===== ВВОД И ПОДТВЕРЖДЕНИЕ ПАРОЛЯ ROOT =====
while true; do
  root_password=$(gum input --password --prompt "Введите пароль root:")
  [ -z "$root_password" ] && {
    gum style --foreground red "Пароль не может быть пустым"
    sleep 1
    continue
  }

  root_password_confirm=$(gum input --password --prompt "Повторите пароль:")

  if [ "$root_password" != "$root_password_confirm" ]; then
    gum style --foreground red "Пароли не совпадают"
    sleep 1
    continue
  fi

  gum style --foreground green "Пароль принят"
  break
done


### ===== УСТАНОВКА ПАРОЛЯ ROOT =====
echo "root:$root_password" | chpasswd
unset root_password root_password_confirm

echo "✔ Пароль root успешно установлен"
