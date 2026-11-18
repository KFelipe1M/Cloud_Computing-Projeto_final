#!/usr/bin/env bash
while true; do
  clear
  date
  lxc list -c ns4mDu
  echo
  echo "Métricas brutas (amostras):"
  lxc query /1.0/metrics | grep -E
'cpu_seconds_total|memory_MemAvailable_bytes|filesystem_avail_bytes' | head -12
  sleep 5
done
