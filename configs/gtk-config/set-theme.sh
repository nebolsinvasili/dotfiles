#!/usr/bin/env bash
set -euo pipefail

# ================= НАСТРОЙКИ =================
GTK_THEME_DIRS=(
  "$HOME/.themes"
  "/usr/share/themes"
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
echo "🔍 Поиск доступных GTK-тем..."

declare -A THEMES
i=1

for base in "${GTK_THEME_DIRS[@]}"; do
  [ -d "$base" ] || continue

  for dir in "$base"/*; do
    [ -d "$dir" ] || continue
    [ -f "$dir/index.theme" ] || continue

    # GTK theme must contain gtk-3.0 at least
    [ -d "$dir/gtk-3.0" ] || continue

    name=$(basename "$dir")
    label=$(grep -E '^Name=' "$dir/index.theme" | cut -d= -f2-)
    label=${label:-$name}

    THEMES[$i]="$name|$label"
    printf "%2d) %s  [%s]\n" "$i" "$label" "$name"
    ((i++))
  done
done

if [ "${#THEMES[@]}" -eq 0 ]; then
  echo "❌ GTK-темы не найдены"
  exit 1
fi

echo
read -rp "👉 Выберите номер темы: " CHOICE

SELECTED="${THEMES[$CHOICE]:-}"
if [ -z "$SELECTED" ]; then
  echo "❌ Неверный выбор"
  exit 1
fi

GTK_THEME="${SELECTED%%|*}"
GTK_LABEL="${SELECTED##*|}"

echo
echo "▶ GTK тема: $GTK_LABEL"
echo "▶ Каталог:  $GTK_THEME"
echo

# ================= GTK =================
apply_gtk() {
  local file="$1"

  # -------- GTK2 --------
  if [[ "$file" == *".gtkrc-2.0" ]]; then
    local target="$file"

    if [ -L "$file" ]; then
      target=$(readlink -f "$file" || true)
      [ -z "$target" ] && return
    fi

    mkdir -p "$(dirname "$target")"
    touch "$target"

    if grep -q '^gtk-theme-name=' "$target"; then
      sed -i 's|^gtk-theme-name=.*|gtk-theme-name="'"$GTK_THEME"'"|' "$target"
    else
      echo 'gtk-theme-name="'"$GTK_THEME"'"' >> "$target"
    fi

    return
  fi

  # -------- GTK3 / GTK4 --------
  mkdir -p "$(dirname "$file")"
  touch "$file"

  grep -q '^\[Settings\]' "$file" || printf "[Settings]\n" >> "$file"

  if grep -q '^gtk-theme-name=' "$file"; then
    sed -i "s|^gtk-theme-name=.*|gtk-theme-name=$GTK_THEME|" "$file"
  else
    sed -i "/^\[Settings\]/a gtk-theme-name=$GTK_THEME" "$file"
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

  sed -i \
    -e "s/^style=.*/style=gtk2/" \
    -e "s/^gtk_theme=.*/gtk_theme=$GTK_THEME/" \
    "$file"

  grep -q "^gtk_theme=" "$file" || \
    sed -i "/^\[Appearance\]/a gtk_theme=$GTK_THEME" "$file"
}

for f in "${QT_FILES[@]}"; do
  apply_qt "$f"
done

echo "🧩 qt5ct / qt6ct обновлены"

# ================= XSETTINGS =================
XSET="$HOME/.config/bspwm/config/xsettingsd"

if [ -f "$XSET" ]; then
  sed -i \
    -e "s|Net/ThemeName .*|Net/ThemeName \"$GTK_THEME\"|" \
    "$XSET"

  pidof xsettingsd >/dev/null && pkill -HUP xsettingsd
  echo "🧠 xsettingsd обновлён"
fi

# ================= GSETTINGS =================
if command -v gsettings >/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
fi

# ================= FLATPAK =================
if command -v flatpak >/dev/null; then
  flatpak override --user \
    --env=GTK_THEME="$GTK_THEME"
fi

# ================= FIN =================
echo
echo "✅ GTK-тема применена"
echo
echo "⚠️ GTK4 + libadwaita:"
echo "   Большинство тем не применяются полностью"
echo "   Рекомендуемые: adw-gtk3, Colloid, Graphite"
echo
echo "🔁 Для 100% эффекта: перелогинься или перезапусти X"

