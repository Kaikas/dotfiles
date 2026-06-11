#!/usr/bin/env bash
# Lay out all connected outputs and (re)launch polybar so each gets a bar.
# Run on i3 startup, on monitor hotplug ($super+p), and on lid open/close.
set -euo pipefail

mapfile -t connected < <(xrandr --query | awk '/ connected/{print $1}')
(( ${#connected[@]} == 0 )) && exit 0

# Detect the internal/laptop output by its eDP* prefix (host-agnostic).
laptop=""
for o in "${connected[@]}"; do
  if [[ "$o" == eDP* ]]; then
    laptop="$o"
    break
  fi
done

# External outputs in xrandr order — used as left → right.
externals=()
for o in "${connected[@]}"; do
  [[ "$o" != "$laptop" ]] && externals+=("$o")
done

lid_closed=0
lid_state_file=$(ls /proc/acpi/button/lid/*/state 2>/dev/null | head -1)
if [[ -n "$lid_state_file" ]] && grep -q closed "$lid_state_file"; then
  lid_closed=1
fi

# Drop the laptop output when the lid is closed AND at least one external is up.
drop_laptop=0
if (( lid_closed )) && [[ -n "$laptop" ]] && (( ${#externals[@]} >= 1 )); then
  drop_laptop=1
fi

active=()
for o in "${connected[@]}"; do
  if (( drop_laptop )) && [[ "$o" == "$laptop" ]]; then
    continue
  fi
  active+=("$o")
done

if (( drop_laptop )); then
  xrandr --output "$laptop" --off
fi

# Primary = leftmost external if any, else the laptop. Externals win so that
# workspaces pinned to them land on the correct physical screen.
if (( ${#externals[@]} >= 1 )); then
  primary="${externals[0]}"
else
  primary="$laptop"
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

# i3's "workspace N output X" rules only fire for fresh workspaces, so
# explicitly migrate existing ones whenever 2+ externals are present.
if (( ${#externals[@]} >= 2 )) && command -v i3-msg >/dev/null 2>&1; then
  left="${externals[0]}"
  right="${externals[1]}"
  focused=$(i3-msg -t get_workspaces 2>/dev/null \
    | awk -F'"' '/"focused":true/{for(i=1;i<NF;i++) if ($i=="name"){print $(i+2); exit}}' || true)
  for ws in 1 2 3 4; do
    i3-msg -q "workspace number $ws; move workspace to output $left" >/dev/null 2>&1 || true
  done
  for ws in 5 6 7 8; do
    i3-msg -q "workspace number $ws; move workspace to output $right" >/dev/null 2>&1 || true
  done
  if [[ -n "$focused" ]]; then
    i3-msg -q "workspace $focused" >/dev/null 2>&1 || true
  fi
fi

"$HOME/.config/polybar/launch.sh"
