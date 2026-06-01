#!/usr/bin/env bash
# Lay out all connected outputs and (re)launch polybar so each gets a bar.
# Run on i3 startup, on monitor hotplug ($super+p), and on lid open/close.
set -euo pipefail

laptop="eDP-1"

mapfile -t connected < <(xrandr --query | awk '/ connected/{print $1}')
(( ${#connected[@]} == 0 )) && exit 0

lid_closed=0
lid_state_file=$(ls /proc/acpi/button/lid/*/state 2>/dev/null | head -1)
if [[ -n "$lid_state_file" ]] && grep -q closed "$lid_state_file"; then
  lid_closed=1
fi

active=()
for o in "${connected[@]}"; do
  if (( lid_closed )) && [[ "$o" == "$laptop" ]] && (( ${#connected[@]} > 1 )); then
    continue
  fi
  active+=("$o")
done

if (( lid_closed )) && (( ${#connected[@]} > 1 )); then
  xrandr --output "$laptop" --off
fi

primary="$laptop"
if ! printf '%s\n' "${active[@]}" | grep -qx "$primary"; then
  primary="${active[0]}"
fi

xrandr --output "$primary" --primary --auto --pos 0x0

prev="$primary"
for out in "${active[@]}"; do
  [[ "$out" == "$primary" ]] && continue
  xrandr --output "$out" --auto --right-of "$prev"
  prev="$out"
done

for out in $(xrandr --query | awk '/ disconnected/{print $1}'); do
  xrandr --output "$out" --off
done

# Host-specific workspace placement (e.g. docked + lid closed).
# i3's "workspace N output X" rules only fire for fresh workspaces, so we
# explicitly migrate existing ones when the layout changes.
host=$(hostname 2>/dev/null | tr '[:upper:]' '[:lower:]')
if [[ "$host" == "erebos" ]] && (( lid_closed )) && (( ${#connected[@]} > 1 )) \
   && command -v i3-msg >/dev/null 2>&1; then
  hdmi="HDMI-1-0"
  usbc="DP-1-1"
  if printf '%s\n' "${active[@]}" | grep -qx "$hdmi"; then
    for ws in 1 2 3 4; do
      i3-msg -q "workspace number $ws; move workspace to output $hdmi" >/dev/null 2>&1 || true
    done
  fi
  if printf '%s\n' "${active[@]}" | grep -qx "$usbc"; then
    for ws in 5 6 7 8; do
      i3-msg -q "workspace number $ws; move workspace to output $usbc" >/dev/null 2>&1 || true
    done
  fi
fi

"$HOME/.config/polybar/launch.sh"
