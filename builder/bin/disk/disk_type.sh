#!/bin/sh

choose_disk_options() {
  # --- Выбор типа диска ---
  local disk_type
  disk_type=$(gum choose "SSD" "HDD" --header "Выберите тип диска:")

  local sub
  case "$disk_type" in
  "SSD") sub='rw,noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol' ;;
  "HDD") sub='rw,relatime,space_cache=v2,autodefrag,nodatacow,subvol' ;;
  esac

  # --- Подтверждение действий через gum ---
  gum style --foreground=212 "Вы выбрали $disk_type с опциями монтирования:"
  gum style --foreground=10 "$sub"

  if gum confirm "Применить эти настройки?" --default=1; then
    echo "$sub"
  else
    gum style --foreground=1 "Действие отменено."
    return 1
  fi
}

# --- Пример использования ---
choose_disk_options
