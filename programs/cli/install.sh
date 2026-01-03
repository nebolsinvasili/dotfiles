#!/bin/bash
# Проходит по всем поддиректориям текущей директории и запускает install.sh

for dir in */; do
    if [ -d "$dir" ]; then
        script="$dir/install.sh"

        if [ -f "$script" ]; then
            if [ ! -x "$script" ]; then
                chmod +x "$script"
            fi

            echo ">>> Запуск: $script"
            (
                cd "$dir" || exit 1
                ./install.sh
            )
        fi
    fi
done

./install-repo.sh
