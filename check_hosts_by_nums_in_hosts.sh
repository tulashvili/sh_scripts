#!/usr/bin/env bash
# check_vpn_hosts.sh
# Проверяет /etc/hosts на наличие хостов вида vpnXXX (только из заданного списка)
# и выводит именно полное имя (например: vpn310-fi-switcherry.htzn)

set -eo pipefail

HOSTS_FILE="${1:-/etc/hosts}"

# Список номеров
nums=(222 254 259 264 271 273 276 282 289 310 317 320 321 323 327 330 335 338 355 367 388 389 390 398 399 406 408 409 410 412 332 480 481)

if [[ ! -r "$HOSTS_FILE" ]]; then
  echo "Ошибка: не удалось прочитать файл $HOSTS_FILE" >&2
  exit 1
fi

found=0

while read -r line; do
  # Убираем комментарии и пустые строки
  line="${line%%#*}"
  [[ -z "$line" ]] && continue

  # Делим строку: IP и список имён
  read -r ip hosts <<< "$line"
  [[ -z "$hosts" ]] && continue

  # Перебираем имена
  for host in $hosts; do
    for num in "${nums[@]}"; do
      # Проверяем наличие vpn<num> и что цифры в имени только эти
      if [[ "$host" == *"vpn${num}"* ]]; then
        digits="$(echo "$host" | tr -cd '0-9')"
        if [[ "$digits" == "$num" ]]; then
          # Проверяем, что имя — полное (с точкой, например .htzn)
          if [[ "$host" == *.* ]]; then
            echo "$host"
            found=1
          fi
          break
        fi
      fi
    done
  done
done < "$HOSTS_FILE"

if [[ $found -eq 0 ]]; then
  echo "Совпадений не найдено."
fi

