#!/usr/bin/env bash
set -euo pipefail

# ================= НАСТРОЙКИ =================
ICON_DIRS=(
  "$HOME/.icons"
  "/usr/share/icons"
)

GTK_FILES=(
  "$HOME/.gtkrc-2.0"
  "$HOME/.config/gtk-3.0/settings.ini"
  "$HOME/.config/gtk-4.0/settings.ini"
)

QT_FILES=(
  "$HOME/.config/qt5ct/qt5ct.conf"
  "$HOME/.config/qt6ct/qt6ct.conf"
)

# ================= ПОИСК ТЕМ =================
echo "🔍 Поиск доступных тем иконок..."

declare -A THEMES
i=1

for base in "${ICON_DIRS[@]}"; do
  [ -d "$base" ] || continue

  for dir in "$base"/*; do
    [ -d "$dir" ] || continue
    [ -f "$dir/index.theme" ] || continue

    # исключаем cursor-only темы
    grep -q "^Directories=" "$dir/index.theme" || continue

    name=$(basename "$dir")
    label=$(grep -E '^Name=' "$dir/index.theme" | cut -d= -f2-)
    label=${label:-$name}

    THEMES[$i]="$name|$label"
    printf "%2d) %s  [%s]\n" "$i" "$label" "$name"
    ((i++))
  done
done

if [ "${#THEMES[@]}" -eq 0 ]; then
  echo "❌ Темы иконок не найдены"
  exit 1
fi

echo
read -rp "👉 Выберите номер темы: " CHOICE

SELECTED="${THEMES[$CHOICE]:-}"
[ -z "$SELECTED" ] && { echo "❌ Неверный выбор"; exit 1; }

ICON_THEME="${SELECTED%%|*}"
ICON_LABEL="${SELECTED##*|}"

echo
echo "▶ Тема иконок: $ICON_LABEL"
echo "▶ Каталог:     $ICON_THEME"
echo

# ================= GTK =================
apply_gtk() {
  local file="$1"

  # ---------- GTK2 ----------
  if [[ "$file" == *".gtkrc-2.0" ]]; then
    local target="$file"

    if [ -L "$file" ]; then
      target=$(readlink -f "$file" || true)
      [ -z "$target" ] && return
    fi

    mkdir -p "$(dirname "$target")"
    touch "$target"

    if grep -q '^gtk-icon-theme-name=' "$target"; then
      sed -i 's|^gtk-icon-theme-name=.*|gtk-icon-theme-name="'"$ICON_THEME"'"|' "$target"
    else
      echo 'gtk-icon-theme-name="'"$ICON_THEME"'"' >> "$target"
    fi

    return
  fi

  # ---------- GTK3 / GTK4 ----------
  mkdir -p "$(dirname "$file")"
  touch "$file"

  grep -q '^\[Settings\]' "$file" || printf "[Settings]\n" >> "$file"

  if grep -q '^gtk-icon-theme-name=' "$file"; then
    sed -i "s|^gtk-icon-theme-name=.*|gtk-icon-theme-name=$ICON_THEME|" "$file"
  else
    sed -i "/^\[Settings\]/a gtk-icon-theme-name=$ICON_THEME" "$file"
  fi
}

for f in "${GTK_FILES[@]}"; do
  apply_gtk "$f"
done

echo "🎨 GTK2 / GTK3 / GTK4 обновлены"

# ================= QT =================
apply_qt() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
  touch "$file"

  grep -q "^\[Appearance\]" "$file" || printf "[Appearance]\n" >> "$file"

  sed -i "s/^icon_theme=.*/icon_theme=$ICON_THEME/" "$file"

  grep -q "^icon_theme=" "$file" || \
    sed -i "/^\[Appearance\]/a icon_theme=$ICON_THEME" "$file"
}

for f in "${QT_FILES[@]}"; do
  apply_qt "$f"
done

echo "🧩 qt5ct / qt6ct обновлены"

# ================= XSETTINGS =================
XSET="$HOME/.config/bspwm/config/xsettingsd"

if [ -f "$XSET" ]; then
  sed -i \
    -e "s|Net/IconThemeName .*|Net/IconThemeName \"$ICON_THEME\"|" \
    "$XSET"

  pidof xsettingsd >/dev/null && pkill -HUP xsettingsd
  echo "🧠 xsettingsd обновлён"
fi

# ================= GSETTINGS =================
if command -v gsettings >/dev/null; then
  gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
fi

# ================= FLATPAK =================
if command -v flatpak >/dev/null; then
  flatpak override --user \
    --env=ICON_THEME="$ICON_THEME" \
    --env=GTK_ICON_THEME="$ICON_THEME"
fi

# ================= FIN =================
echo
echo "✅ Тема иконок установлена"
echo
echo "🔁 Для полного применения:"
echo "   • перезапусти приложения"
echo "   • или перелогинься"

