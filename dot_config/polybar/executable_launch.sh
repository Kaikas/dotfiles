#!/usr/bin/env bash
set -euo pipefail

# Serialize concurrent invocations so killall+spawn can't race into duplicates
# (XF86Display fires on resume in parallel with exec_always re-runs).
exec 9>"/tmp/polybar-launch-$UID.lock"
flock -x 9

killall -q polybar || true
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.1; done

CFG="$HOME/.config/polybar/config.ini"

if command -v xrandr >/dev/null 2>&1; then
  primary="$(xrandr --query | awk '/ primary/{print $1; exit}')"

  # Use --listmonitors so disabled-but-connected outputs (e.g. eDP-1 with the
  # lid closed) don't cause polybar to fall back onto the primary output.
  # FD 9 holds the launch lock; close it in children so polybar doesn't
  # inherit and keep the lock alive after this script exits.
  while IFS= read -r m; do
    if [[ "$m" == "$primary" ]]; then
      MONITOR="$m" polybar -c "$CFG" --reload main 9>&- &
    else
      MONITOR="$m" polybar -c "$CFG" --reload main_notray 9>&- &
    fi
  done < <(xrandr --listmonitors | awk 'NR>1 {print $NF}')
else
  polybar -c "$CFG" --reload main 9>&- &
fi

