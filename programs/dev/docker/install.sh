#!/bin/sh

# Установка Docker
yay -S docker docker-compose --noconfirm

# Запуск и настройка Docker
sudo systemctl start docker
