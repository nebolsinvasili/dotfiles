#!/usr/bin/env bash
set -euo pipefail


### ===== ВВОД ИМЕНИ ПОЛЬЗОВАТЕЛЯ =====
while true; do
  username=$(gum input --prompt "Введите имя пользователя:")

  if [ -z "$username" ]; then
    gum style --foreground red "Имя пользователя не может быть пустым"
    continue
  fi

  if ! [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    gum style --foreground red "Недопустимое имя пользователя"
    continue
  fi

  if gum confirm "Использовать имя пользователя: $username ?"; then
    break
  fi
done


### ===== ВЫБОР ГРУПП (БЕЗ WHEEL) =====
# Исключаем wheel из выбора в списке
selected=$(cut -d: -f1 /etc/group | grep -v "^wheel$" | gum filter \
  --height 20 \
  --no-limit \
  --prompt "Выберите дополнительные группы для пользователя (Tab — несколько):"
)

# Преобразуем выбранные группы в CSV
groups_list=""
if [ -n "$selected" ]; then
  groups_list=$(echo "$selected" | paste -sd "," -)
fi


### ===== ВЫБОР ГРУППЫ WHEEL =====
if gum confirm "Добавить пользователя $username в sudo (wheel)?"; then
  if [ -n "$groups_list" ]; then
    groups_list="$groups_list,wheel"
  else
    groups_list="wheel"
  fi
fi


### ===== ВВОД ПАРОЛЯ =====
while true; do
  password=$(gum input --password --prompt "Введите пароль для $username:")
  [ -z "$password" ] && { gum style --foreground red "Пароль не может быть пустым"; continue; }

  password_confirm=$(gum input --password --prompt "Повторите пароль:")
  if [ "$password" != "$password_confirm" ]; then
    gum style --foreground red "Пароли не совпадают"
    continue
  fi

  gum style --foreground green "Пароль принят"
  break
done


### ===== СОЗДАНИЕ ПОЛЬЗОВАТЕЛЯ =====
if ! id "$username" &>/dev/null; then
  useradd -m -s /bin/bash -G "$groups_list" "$username"
fi


### ===== УСТАНОВКА ПАРОЛЯ =====
echo "$username:$password" | chpasswd
unset password password_confirm


### ===== ВЫВОД =====
echo
gum style --foreground yellow "Имя пользователя: $username"
gum style --foreground yellow "Группы: ${groups_list:-none}"
gum style --foreground green "Пароль успешно установлен"
echo "✔ Пользователь $username успешно создан"

