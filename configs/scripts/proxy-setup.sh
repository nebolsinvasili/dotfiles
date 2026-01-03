#!/bin/bash
#
# Proxy setup script with config file support
#

usage() {
    cat <<EOF
Использование: $0 --user=<USERNAME> --pass=<PASSWORD> --host=<IP> --port=<PORT> [--global]
Параметры:
  --user       Логин для прокси
  --pass       Пароль для прокси
  --host       IP-адрес или домен прокси
  --port       Порт прокси
  --global     Установить глобально (в /etc/profile.d/proxy.sh)
  --config     Загрузить параметры из конфигурационного файла
  -h, --help   Показать эту справку и выйти

Примеры:
  $0 --user=alice --pass=secret --host=192.168.1.10 --port=8080 --global
  $0 --config=proxy.conf
EOF
    exit 1
}

SET_GLOBAL=false
CONFIG_FILE=""

# === Парсинг параметров ===
for arg in "$@"; do
    case $arg in
        --user=*)   PROXY_USER="${arg#*=}" ;;
        --pass=*)   PROXY_PASS="${arg#*=}" ;;
        --host=*)   PROXY_HOST="${arg#*=}" ;;
        --port=*)   PROXY_PORT="${arg#*=}" ;;
        --global)   SET_GLOBAL=true ;;
        --config=*) CONFIG_FILE="${arg#*=}" ;;
        -h|--help)  usage ;;
        *) echo "Неизвестный параметр: $arg"; usage ;;
    esac
done

# === Если задан config-файл ===
if [[ -n "$CONFIG_FILE" ]]; then
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Ошибка: конфигурационный файл $CONFIG_FILE не найден!"
        exit 1
    fi
    echo "[+] Загружаем настройки из $CONFIG_FILE"
    while IFS='=' read -r key value; do
        case "$key" in
            user)   PROXY_USER="$value" ;;
            pass)   PROXY_PASS="$value" ;;
            host)   PROXY_HOST="$value" ;;
            port)   PROXY_PORT="$value" ;;
            global) [[ "$value" =~ ^(true|1|yes)$ ]] && SET_GLOBAL=true ;;
        esac
    done < <(grep -v '^#' "$CONFIG_FILE" | grep .)
fi

# === Проверка обязательных параметров ===
if [[ -z "${PROXY_USER:-}" || -z "${PROXY_PASS:-}" || -z "${PROXY_HOST:-}" || -z "${PROXY_PORT:-}" ]]; then
    echo "Ошибка: не все обязательные параметры заданы!"
    usage
fi

# === Переменные ===
PROXY_URL="http://${PROXY_USER}:${PROXY_PASS}@${PROXY_HOST}:${PROXY_PORT}/"

# === Настройка глобальная или локальная ===
if $SET_GLOBAL; then
    echo "[+] Creating global proxy config in /etc/profile.d/proxy.sh..."
    
    sudo tee /etc/profile.d/proxy.sh > /dev/null <<EOF
#!/bin/sh
export http_proxy="${PROXY_URL}"
export https_proxy="${PROXY_URL}"
export ftp_proxy="${PROXY_URL}"
export no_proxy="localhost,127.0.0.1,::1"
EOF
    sudo chmod +x /etc/profile.d/proxy.sh

    echo "[+] Updating sudoers to preserve proxy variables..."
    if ! sudo grep -q 'env_keep += "http_proxy https_proxy' /etc/sudoers; then
        echo 'Defaults env_keep += "http_proxy https_proxy ftp_proxy no_proxy"' | sudo tee -a /etc/sudoers
    else
        echo "[✓] sudo already configured for proxy variables"
    fi
else
    echo "[+] Setting proxy variables only for current user..."
    
    # Удаляем старые строки про proxy, если есть
    sed -i '/# Proxy settings/,+5d' ~/.bashrc

    # Добавляем новый блок
    cat >> ~/.bashrc <<EOF
# Proxy settings
export http_proxy="${PROXY_URL}"
export https_proxy="${PROXY_URL}"
export ftp_proxy="${PROXY_URL}"
export no_proxy="localhost,127.0.0.1,::1"
EOF
    source ~/.bashrc
fi

# === Немедленное применение для текущего сеанса ===
echo "[+] Exporting proxy variables in current shell..."
export http_proxy="${PROXY_URL}"
export https_proxy="${PROXY_URL}"
export ftp_proxy="${PROXY_URL}"
export no_proxy="localhost,127.0.0.1,::1"

# === Проверка ===
echo "[+] Checking proxy connection using curl..."
if curl --silent https://api.ipify.org --max-time 10; then
    echo -e "\n[✓] Proxy is set up and working."
else
    echo "[!] Proxy check failed."
fi

echo "[✔] Proxy configuration complete. Reboot or re-login to fully apply."
