#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Запустите скрипт от имени root (через su -)"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"

echo "=== 1. Установка зависимостей из локальной папки ==="
apt-get install -y "$SCRIPT_DIR"/repo_deps/*.rpm

echo "=== 2. Установка КриптоПро CSP ==="
CP_DIR="$SCRIPT_DIR/cryptopro"
apt-get install -y \
  "$CP_DIR"/cprocsp-curl*.rpm \
  "$CP_DIR"/lsb-cprocsp-base*.rpm \
  "$CP_DIR"/lsb-cprocsp-capilite*.rpm \
  "$CP_DIR"/lsb-cprocsp-kc1-64*.rpm \
  "$CP_DIR"/lsb-cprocsp-rdr-64*.rpm

apt-get install -y \
  "$CP_DIR"/cprocsp-rdr-gui-gtk*.rpm \
  "$CP_DIR"/cprocsp-rdr-rutoken*.rpm \
  "$CP_DIR"/cprocsp-rdr-pcsc*.rpm \
  "$CP_DIR"/lsb-cprocsp-pkcs11*.rpm

apt-get install -y "$CP_DIR"/cprocsp-rdr-cryptoki*.rpm
apt-get install -y "$CP_DIR"/cprocsp-cptools*.rpm

echo "=== 3. Установка драйверов Pantum ==="
rpm -Uvh --replacepkgs "$SCRIPT_DIR"/pantum-*.rpm

echo "=== 4. Установка драйверов Fujitsu SP-1120 ==="
apt-get install -y "$SCRIPT_DIR"/pfusp-*.rpm
cp -f /usr/lib/sane/libsane-pfusp* /usr/lib64/sane/
cp -f "$SCRIPT_DIR"/60-pfusp.rules /etc/udev/rules.d/60-pfusp.rules

echo "=== 5. Установка драйверов Avision AV332U ==="
rpm -Uvh --replacepkgs "$SCRIPT_DIR"/scanner-driver-avision-*.rpm

echo "=== 6. Перезагрузка правил udev ==="
udevadm control --reload-rules
udevadm trigger

echo "Готово! Все компоненты успешно установлены."
