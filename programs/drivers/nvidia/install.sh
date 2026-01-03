#!/bin/sh
set -e  # Прекращаем выполнение при ошибке

source $HOME/dotfiles/dot-installer/scripts/choose_option.sh

# === Определение пути к скрипту choose.sh ===
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# if [[ -f "$SCRIPT_DIR/../scripts/choose.sh" ]]; then
#     source "$SCRIPT_DIR/../scripts/choose.sh"
# else
#     echo "Ошибка: не найден $SCRIPT_DIR/../scripts/choose.sh"
#     exit 1
# fi

# === Установка драйверов NVIDIA ===
echo "[+] Устанавливаю драйверы NVIDIA..."
yay -S --needed --noconfirm nvidia nvidia-utils nvidia-settings

# === Установка CUDA (по желанию пользователя) ===
if choose_installation "Хотите установить CUDA?" "N"; then
    echo "[+] Устанавливаю CUDA..."
    if yay -Si cuda &>/dev/null; then
        yay -S --needed --noconfirm cuda
        echo "[✓] CUDA установлена."
    else
        echo "[!] Пакет cuda не найден в репозиториях. Проверьте /etc/pacman.conf."
    fi
else
    echo "[i] Установка CUDA пропущена."
fi
