#!/bin/sh

# Установка Docker
yay -S docker docker-compose --noconfirm

# Запуск и настройка Docker
sudo systemctl start docker.service
sudo systemctl enable docker.service

sudo usermod -aG docker $USER && newgrp docker
