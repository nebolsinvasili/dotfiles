#!/bin/sh

# ===========================
# TOML dependency parser
# ===========================

should_process_block() {
    block="$1"

    # --only имеет приоритет
    if [ -n "$ONLY_BLOCKS" ]; then
        echo "$ONLY_BLOCKS" | tr ',' '\n' | grep -qx "$block" || return 1
    fi

    # --skip
    if [ -n "$SKIP_BLOCKS" ]; then
        echo "$SKIP_BLOCKS" | tr ',' '\n' | grep -qx "$block" && return 1
    fi

    return 0
}

parse_toml_dependencies() {
    local current_block=""
    local enabled="true"
    local in_packages=0
    local packages=""

    while IFS= read -r line || [ -n "$line" ]; do
        # Удаляем комментарии
        line="${line%%#*}"
        line="$(echo "$line" | sed 's/[[:space:]]*$//')"

        # Пусто
        [ -z "$line" ] && continue

        # Новый блок
        if [[ "$line" =~ ^\[(.*)\]$ ]]; then
            current_block="${BASH_REMATCH[1]}"
            enabled="true"
            continue
        fi

        # enabled = false
        if [[ "$line" =~ enabled[[:space:]]*=[[:space:]]*(true|false) ]]; then
            enabled="${BASH_REMATCH[1]}"
            continue
        fi

        # Начало packages
        if [[ "$line" =~ packages[[:space:]]*=[[:space:]]*\[ ]]; then
            in_packages=1
            packages=""
            continue
        fi

        # Читаем массив
        if [ "$in_packages" -eq 1 ]; then
            if [[ "$line" =~ \] ]]; then
                in_packages=0

                if [ "$enabled" = "true" ] && should_process_block "$current_block"; then
                    log_info "Installing block: $current_block"
                    install_block_packages "$current_block" "$packages"
                else
                    log_warn "Skipping block: $current_block"
                fi

                packages=""
                continue
            fi

            pkg="$(echo "$line" | tr -d '",[:space:]')"
            [ -n "$pkg" ] && packages="$packages $pkg"
        fi
    done < "$DEPENDENCIES_FILE"
}

