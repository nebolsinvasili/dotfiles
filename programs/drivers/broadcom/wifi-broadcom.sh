#!/bin/sh
set -e  # Остановить выполнение при ошибке

# === Проверка наличия yay ===
if ! command -v yay &>/dev/null; then
    echo "[!] yay не установлен. Установите его прежде чем продолжить."
    echo "    Руководство: https://wiki.archlinux.org/title/yay"
    exit 1
fi

# === Проверка наличия пакета в AUR ===
if yay -Si broadcom-wl-dkms &>/dev/null; then
    echo "[+] Устанавливаю broadcom-wl-dkms..."
    yay -S --needed --noconfirm broadcom-wl-dkms
    echo "[✓] Установка завершена."
else
    echo "[!] Пакет broadcom-wl-dkms не найден в AUR. Возможно, он переименован или удалён."
fi
