#!/usr/bin/env bash
set -euo pipefail

killall -q polybar || true
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.1; done

CFG="$HOME/.config/polybar/config.ini"

if command -v xrandr >/dev/null 2>&1; then
  primary="$(xrandr --query | awk '/ primary/{print $1; exit}')"

  while IFS= read -r m; do
    if [[ "$m" == "$primary" ]]; then
      MONITOR="$m" polybar -c "$CFG" --reload main &
    else
      MONITOR="$m" polybar -c "$CFG" --reload main_notray &
    fi
  done < <(xrandr --query | awk '/ connected/{print $1}')
else
  polybar -c "$CFG" --reload main &
fi

