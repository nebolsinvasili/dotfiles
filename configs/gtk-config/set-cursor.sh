#!/usr/bin/env bash
set -euo pipefail

# ================= НАСТРОЙКИ =================
DEFAULT_SIZE=24

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
echo "🔍 Поиск доступных тем курсоров..."

declare -A THEMES
i=1

for base in "${ICON_DIRS[@]}"; do
  [ -d "$base" ] || continue

  for dir in "$base"/*; do
    [ -d "$dir" ] || continue
    [ -d "$dir/cursors" ] || continue
    [ -f "$dir/index.theme" ] || continue

    dir_name=$(basename "$dir")
    display_name=$(grep -E '^Name=' "$dir/index.theme" | cut -d= -f2-)
    display_name=${display_name:-$dir_name}

    THEMES[$i]="$dir_name|$display_name"
    printf "%2d) %s  [%s]\n" "$i" "$display_name" "$dir_name"
    ((i++))
  done
done

if [ "${#THEMES[@]}" -eq 0 ]; then
  echo "❌ Курсорные темы не найдены"
  exit 1
fi

echo
read -rp "👉 Выберите номер темы: " CHOICE

SELECTED="${THEMES[$CHOICE]:-}"
if [ -z "$SELECTED" ]; then
  echo "❌ Неверный выбор"
  exit 1
fi

CURSOR_DIR="${SELECTED%%|*}"
CURSOR_LABEL="${SELECTED##*|}"

# ================= РАЗМЕР =================
read -rp "🖱 Размер курсора [по умолчанию $DEFAULT_SIZE]: " CURSOR_SIZE
CURSOR_SIZE="${CURSOR_SIZE:-$DEFAULT_SIZE}"

echo
echo "▶ Тема:   $CURSOR_LABEL"
echo "▶ Каталог: $CURSOR_DIR"
echo "▶ Размер: $CURSOR_SIZE"
echo

# ================= DEFAULT =================
mkdir -p "$HOME/.icons/default"
cat > "$HOME/.icons/default/index.theme" <<EOF
[Icon Theme]
Inherits=$CURSOR_DIR
EOF

echo "🧷 default cursor установлен"

# ================= GTK =================
apply_gtk() {
  local file="$1"

  # ================= GTK2 =================
  if [[ "$file" == *".gtkrc-2.0" ]]; then
    local target="$file"

    if [ -L "$file" ]; then
      target=$(readlink -f "$file" || true)
      if [ -z "$target" ]; then
        echo "⚠️ GTK2: битый симлинк, пропуск"
        return
      fi
      echo "🔗 GTK2: правка цели → $target"
    fi

    mkdir -p "$(dirname "$target")"
    [ -f "$target" ] || touch "$target"

    # replace or append (GTK2 — строго!)
    if grep -q '^gtk-cursor-theme-name=' "$target"; then
      sed -i 's|^gtk-cursor-theme-name=.*|gtk-cursor-theme-name="'"$CURSOR_DIR"'"|' "$target"
    else
      echo 'gtk-cursor-theme-name="'"$CURSOR_DIR"'"' >> "$target"
    fi

    if grep -q '^gtk-cursor-theme-size=' "$target"; then
      sed -i 's|^gtk-cursor-theme-size=.*|gtk-cursor-theme-size='"$CURSOR_SIZE"'|' "$target"
    else
      echo 'gtk-cursor-theme-size='"$CURSOR_SIZE" >> "$target"
    fi

    return
  fi

  # ================= GTK3 / GTK4 =================
  mkdir -p "$(dirname "$file")"
  [ -f "$file" ] || touch "$file"

  grep -q '^\[Settings\]' "$file" || printf "[Settings]\n" >> "$file"

  if grep -q '^gtk-cursor-theme-name=' "$file"; then
    sed -i "s|^gtk-cursor-theme-name=.*|gtk-cursor-theme-name=$CURSOR_DIR|" "$file"
  else
    sed -i "/^\[Settings\]/a gtk-cursor-theme-name=$CURSOR_DIR" "$file"
  fi

  if grep -q '^gtk-cursor-theme-size=' "$file"; then
    sed -i "s|^gtk-cursor-theme-size=.*|gtk-cursor-theme-size=$CURSOR_SIZE|" "$file"
  else
    sed -i "/^\[Settings\]/a gtk-cursor-theme-size=$CURSOR_SIZE" "$file"
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

  if ! grep -q "^\[Appearance\]" "$file"; then
    printf "[Appearance]\n" >> "$file"
  fi

  sed -i \
    -e "s/^cursor_theme=.*/cursor_theme=$CURSOR_DIR/" \
    -e "s/^cursor_size=.*/cursor_size=$CURSOR_SIZE/" \
    "$file"

  grep -q "^cursor_theme=" "$file" || \
    sed -i "/^\[Appearance\]/a cursor_theme=$CURSOR_DIR" "$file"

  grep -q "^cursor_size=" "$file" || \
    sed -i "/^\[Appearance\]/a cursor_size=$CURSOR_SIZE" "$file"
}

for f in "${QT_FILES[@]}"; do
  apply_qt "$f"
done

echo "🧩 qt5ct / qt6ct обновлены"

# ================= XCURSOR =================
XR="$HOME/.Xresources"
touch "$XR"

sed -i \
  -e "s/^Xcursor.theme:.*/Xcursor.theme: $CURSOR_DIR/" \
  -e "s/^Xcursor.size:.*/Xcursor.size: $CURSOR_SIZE/" \
  "$XR"

grep -q "^Xcursor.theme:" "$XR" || echo "Xcursor.theme: $CURSOR_DIR" >> "$XR"
grep -q "^Xcursor.size:"  "$XR" || echo "Xcursor.size: $CURSOR_SIZE" >> "$XR"

xrdb "$XR"

echo "🧠 Xresources обновлены"

# ================= FIN =================
echo
echo "✅ Курсор установлен"
echo
echo "ℹ️ Рекомендуется добавить в ~/.xinitrc (перед WM):"
echo "   xsetroot -cursor_name left_ptr &"
echo
echo "🔁 Для полного применения: перелогинься или перезапусти X"

