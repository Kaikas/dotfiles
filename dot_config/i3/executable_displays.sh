#!/usr/bin/env bash
# Lay out all connected outputs and (re)launch polybar so each gets a bar.
# Run on i3 startup and on monitor hotplug ($super+p).
set -euo pipefail

mapfile -t connected < <(xrandr --query | awk '/ connected/{print $1}')
(( ${#connected[@]} == 0 )) && exit 0

primary="eDP-1"
if ! printf '%s\n' "${connected[@]}" | grep -qx "$primary"; then
  primary="${connected[0]}"
fi

xrandr --output "$primary" --primary --auto --pos 0x0

prev="$primary"
for out in "${connected[@]}"; do
  [[ "$out" == "$primary" ]] && continue
  xrandr --output "$out" --auto --right-of "$prev"
  prev="$out"
done

for out in $(xrandr --query | awk '/ disconnected/{print $1}'); do
  xrandr --output "$out" --off
done

"$HOME/.config/polybar/launch.sh"
