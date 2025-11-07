#!/bin/bash
# Обновление систем с Debian10 до Debian 12
sudo bash
debv=$(cat /etc/debian_version|awk -F. {'print $1'})
fixcrypt () {
   cd /tmp
   apt -y download libcrypt1
   dpkg-deb -x libcrypt* .
   cp -av lib/x86_64-linux-gnu/* /lib/x86_64-linux-gnu/
   apt -y --fix-broken install
   reboot
}
deb10update () {
   systemctl disable haproxy --now
   systemctl disable nginx --now
   systemctl disable monit --now
   mkdir /backup
   rsync -avP /etc /backup/
   dpkg --get-selections "*" > /backup/dpkg.list
   apt update -y && apt upgrade -y
   apt install gcc-8-base
cat <<'REPS' > /etc/apt/sources.list
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main
deb http://ftp.debian.org/debian bullseye-backports main contrib non-free
REPS
   apt update
   apt -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" full-upgrade -y || fixcrypt
   reboot
}

deb11update () {
   systemctl disable haproxy --now
   systemctl disable nginx --now
   systemctl disable monit --now
cat <<'REPS' > /etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main
deb http://ftp.debian.org/debian bookworm-backports main contrib non-free
REPS
   apt update
   apt -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" full-upgrade -y
   reboot
}

justenable () {
systemctl enable haproxy --now
systemctl enable nginx --now
systemctl enable monit --now
}
case $debv in
    10)
        echo "Обнаружен Debian 10, выполняю обновление..."
        deb10update
    ;;
    11)
        echo "Обнаружен Debian 11, выполняю обновление..."
        deb11update
    ;;
    12)
        echo "Уже установлен Debian 12, обновление не требуется, реактивирую сервисы..."
        justenable
    ;;
     *)
        echo "Не удалось определить текущую версию дебиана"
esac

