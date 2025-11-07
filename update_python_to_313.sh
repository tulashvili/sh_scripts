#!/bin/bash
set -e

# === Цвета ===
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; NC='\033[0m'
log() { echo -e "${G}[+] $1${NC}"; }
warn() { echo -e "${Y}[!] $1${NC}"; }
error() { echo -e "${R}[ERROR] $1${NC}"; exit 1; }

# === Переменные ===
PYENV_ROOT="/usr/local/pyenv"
PYTHON_VERSION="3.13.0"

# === 1. Установка зависимостей ===
log "Установка зависимостей..."
apt update
apt install -y \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev git ca-certificates

# === 2. Установка pyenv ===
log "Установка pyenv в $PYENV_ROOT..."
if [ -d "$PYENV_ROOT" ]; then
    cd "$PYENV_ROOT" && git pull >/dev/null 2>&1
else
    git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
fi

# Сборка pyenv
cd "$PYENV_ROOT"
if [ -f "src/Makefile" ]; then
    make -C src >/dev/null 2>&1 || true
else
    src/configure && make -C src
fi

# === 3. Активация pyenv в текущей сессии ===
log "Активация pyenv..."
export PYENV_ROOT="$PYENV_ROOT"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# === 4. Установка Python 3.13.0 ===
log "Установка Python $PYTHON_VERSION..."
if pyenv versions | grep -q "$PYTHON_VERSION"; then
    warn "Python $PYTHON_VERSION уже установлен. Пропускаем."
else
    PYENV_ROOT="$PYENV_ROOT" pyenv install "$PYTHON_VERSION"
fi

# === 5. Глобальная версия ===
log "Установка глобальной версии: $PYTHON_VERSION"
PYENV_ROOT="$PYENV_ROOT" pyenv global "$PYTHON_VERSION"

# === 6. Настройка для всех пользователей ===
log "Настройка /etc/bash.bashrc..."
{
    echo
    echo "# === pyenv ==="
    echo "export PYENV_ROOT=\"$PYENV_ROOT\""
    echo "export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    echo 'eval "$(pyenv init --path)"'
    echo 'eval "$(pyenv init -)"'
} >> /etc/bash.bashrc

# === 7. Права ===
log "Исправление прав..."
chown -R root:root "$PYENV_ROOT"
chmod -R 755 "$PYENV_ROOT/shims" "$PYENV_ROOT/versions"

# === 8. Обновление pip ===
log "Обновление pip..."
pip install --upgrade pip

# === 9. Финальная проверка ===
log "ПРОВЕРКА УСТАНОВКИ:"
echo "----------------------------------------"
python -V
which python
pyenv version
echo "----------------------------------------"

log "ГОТОВО!"
echo
echo "  Перезайдите в shell:"
echo "      exec bash"
echo
echo "  Теперь:"
echo "      python -V  → Python $PYTHON_VERSION"
echo "      pip -V     → актуальный pip"
echo "      pyenv versions → список версий"