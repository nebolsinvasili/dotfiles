#!/usr/bin/env bash
# ============================================================
#
# ██████╗ ███████╗██████╗ ███████╗███╗   ██╗██████╗ ███████╗███╗   ██╗ ██████╗██╗███████╗███████╗
# ██╔══██╗██╔════╝██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔════╝████╗  ██║██╔════╝██║██╔════╝██╔════╝
# ██║  ██║█████╗  ██████╔╝█████╗  ██╔██╗ ██║██║  ██║█████╗  ██╔██╗ ██║██║     ██║█████╗  ███████╗
# ██║  ██║██╔══╝  ██╔═══╝ ██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██║╚██╗██║██║     ██║██╔══╝  ╚════██║
# ██████╔╝███████╗██║     ███████╗██║ ╚████║██████╔╝███████╗██║ ╚████║╚██████╗██║███████╗███████║
# ╚═════╝ ╚══════╝╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝╚═╝╚══════╝╚══════╝
# ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗
# ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
# ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
# ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
# ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
# ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
#
#  Project  : Dependencies Installer
#  Purpose  : Install packages from TOML configuration file in blocks
#  Author   : nebolsinvasili
#  Repo     : https://github.com/nebolsinvasili/dotfiles.git
#
#  License  : GPL-3.0
#  Created  : 2021
#  Updated  : 2025-03-24
#
# ============================================================


set -euo pipefail

# ------------------------------------------------------------
# Load modules
# ------------------------------------------------------------
LOGGING_MODULE="$DOTFILES/.settings/logging"
[[ -r "$LOGGING_MODULE" ]] && source "$LOGGING_MODULE" \
    || printf 'WARNING: logging module not found: %s\n' "$LOGGING_MODULE" >&2

LINKED_MODULE="$DOTFILES/.settings/linked"
[[ -r "$LINKED_MODULE" ]] && source "$LINKED_MODULE" \
    || printf 'WARNING: linked module not found: %s\n' "$LINKED_MODULE" >&2

GIT_MODULE="$DOTFILES/.settings/git-utils"
[[ -r "$GIT_MODULE" ]] && source "$GIT_MODULE" \
    || printf 'WARNING: git utils module not found: %s\n' "$GIT_MODULE" >&2

REPLACE_MODULE="$DOTFILES/.settings/replace"
[[ -r "$REPLACE_MODULE" ]] && source "$REPLACE_MODULE" \
    || printf 'WARNING: replace module not found: %s\n' "$REPLACE_MODULE" >&2

DepInst_MODULE="$DOTFILES/.settings/DependenciesInstaller"
[[ -r "$DepInst_MODULE" ]] && source "$DepInst_MODULE" \
    || printf 'WARNING: dependencies module not found: %s\n' "$DepInst_MODULE" >&2


# ------------------------------------------------------------
# Default values
# ------------------------------------------------------------


# ------------------------------------------------------------
# Modules
# ------------------------------------------------------------

configure_pacman() {
    local conf="/etc/pacman.conf"

    # Проверка существования файла перед редактированием
    if [ ! -f "$conf" ]; then
        echo "error: pacman.conf not found at $conf" >&2
        return 1
    fi

    echo "Configuring pacman.conf at $conf..."

    # 1. Раскомментируем и устанавливаем количество параллельных загрузок
    # Используем ^# для точности, чтобы не задеть уже измененные строки
    replace_regex -n -f "$conf" '^#ParallelDownloads.*' 'ParallelDownloads = 10'

    # 2. Включаем подробные списки пакетов
    replace_regex -n -f "$conf" '^#VerbosePkgLists' 'VerbosePkgLists'

    # 3. Включаем Color и добавляем пасхалку ILoveCandy
    # Заменяем закомментированный Color на ILoveCandy
    replace_regex -n -f "$conf" '^#Color' 'ILoveCandy'

    # 4. Включаем репозиторий [multilib]
    # Так как это блок из двух строк, надежнее всего раскомментировать 
    # конкретно заголовок и следующую за ним строку Include.
    replace_regex -n -f "$conf" '^#\[multilib\]' '[multilib]'
    # Раскомментируем Include, который идет сразу после [multilib]
    # Используем стандартный sed для точности в диапазоне, 
    # так как replace_regex не знает о контексте строк
    sed -i '/^\[multilib\]/,/^#Include/ s/^#//' "$conf"

    echo "Pacman configuration complete."
}

configure_sudoers() {
    local sudoers="/etc/sudoers"

    if [ ! -f "$sudoers" ]; then
        echo "error: sudoers file not found at $sudoers" >&2
        return 1
    fi

    echo "Configuring sudoers at $sudoers..."

    # Раскомментируем группу %wheel для предоставления прав администратора.
    # Используем [[:space:]]* для обработки возможных вариаций пробелов.
    # Флаг -n отключает создание .bak файла.
    replace_regex -n -f "$sudoers" '^#[[:space:]]*%wheel ALL=\(ALL:ALL\) ALL' '%wheel ALL=(ALL:ALL) ALL'

    echo "Sudo configuration complete."
}


# ============================================================
# main entry (cli)
# ============================================================
main() {

    log_init "$LOG" && log_title "Pacman configuration manager started"

    configure_pacman
}

# ============================================================
# main entry
# ============================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi

