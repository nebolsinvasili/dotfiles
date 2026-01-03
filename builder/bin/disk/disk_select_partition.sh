#!/usr/bin/env sh

choose_partitions() {
  local disk="$1"
  [[ -z "$disk" ]] && {
    echo "Диск не указан"
    return 1
  }

  local partitions
  partitions=$(lsblk -ln -o NAME "${disk}" | grep -E "^$(basename "$disk")[0-9]+")
  [[ -z "$partitions" ]] && {
    echo "На диске нет разделов"
    return 1
  }

  local options=$(echo -e "<пусто>\n$partitions")
  local boot="" root="" swap="" home=""

  # --- Функция для генерации заголовка ---
  header() {
    echo -e "Текущий выбор:\nBoot: ${boot:-<не выбрано>}\nRoot: ${root:-<не выбрано>}\nSwap: ${swap:-<не выбрано>}\nHome: ${home:-<не выбрано>}"
  }

  # --- Выбор Boot ---
  boot=$(echo "$options" | gum choose --header "$(header)")
  [[ "$boot" == "<пусто>" ]] && boot=""

  # --- Выбор Root (обязательно) ---
  while true; do
    root=$(echo "$options" | gum choose --header "$(header)")
    [[ "$root" != "<пусто>" ]] && break
    gum style --foreground=1 "Root раздел обязателен!"
  done

  # --- Выбор Swap ---
  swap=$(echo "$options" | gum choose --header "$(header)")
  [[ "$swap" == "<пусто>" ]] && swap=""

  # --- Выбор Home ---
  home=$(echo "$options" | gum choose --header "$(header)")
  [[ "$home" == "<пусто>" ]] && home=""

  # --- Финальный выбор ---
  echo "boot=$boot"
  echo "root=$root"
  echo "swap=$swap"
  echo "home=$home"
}

disk="/dev/sda"
choose_partitions "$disk"
