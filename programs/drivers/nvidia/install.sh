#!/bin/sh
set -e  # Прекращаем выполнение при ошибке

# === Установка драйверов NVIDIA ===
echo "[+] Устанавливаю драйверы NVIDIA..."
yay -S nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils --needed --noconfirm
yay -S nvidia-580xx-settings --needed --noconfirm
yay -S opencl-nvidia-580xx lib32-opencl-nvidia-580xx --needed --noconfirm

sudo pacman -Syu

# === Установка CUDA (по желанию пользователя) ===
gum confirm "Хотите установить CUDA?" || { echo "[i] Установка CUDA пропущена."; exit 0; }

echo "[+] Устанавливаю CUDA..."

# Проверяем, доступен ли пакет cuda в репозиториях с помощью yay
if yay -Si cuda &>/dev/null; then
    yay -S cuda cudnn opencv-cuda --needed --noconfirm
    echo "[✓] CUDA успешно установлена."
else
    echo "[!] Пакет cuda не найден в репозиториях. Проверьте /etc/pacman.conf."
fi
