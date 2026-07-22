#!/usr/bin/env bash
# Event-driven monitor reconfiguration — replaces the old 2s xrandr poll.
#
# Listens for X RandR output-change events via `xev -root -event randr`
# (no polling, no periodic `xrandr --query` wakeups) and re-runs displays.sh
# once the events settle. The settle/debounce is essential: a single NVIDIA
# DP-MST link retrain emits a *burst* of connect/disconnect events over ~1s;
# acting on each one would fire displays.sh several times and black the
# screens repeatedly. We coalesce a burst into exactly one reconfigure.
#
# xev is used (not /sys/class/drm) because the NVIDIA proprietary driver does
# not expose DisplayPort MST sub-stream connectors via sysfs. stdbuf forces
# line-buffered output so events are delivered promptly, not block-buffered.
set -uo pipefail

SETTLE=2  # seconds of event-quiet required before reconfiguring
RUNDIR="${XDG_RUNTIME_DIR:-/tmp}"
STAMP="$RUNDIR/i3-monitor-hotplug.stamp"
LOCK="$RUNDIR/i3-monitor-hotplug.lock"

# Wait until no RandR event has arrived for $SETTLE seconds, then reconfigure.
# Single-flight via flock: while one settler waits, further events only bump
# the stamp (see the read loop) and this same worker keeps extending its wait.
settle_and_apply() {
  exec 9>"$LOCK"
  flock -n 9 || return 0
  local last cur
  while :; do
    last=$(cat "$STAMP" 2>/dev/null || echo 0)
    sleep "$SETTLE"
    cur=$(cat "$STAMP" 2>/dev/null || echo 0)
    [[ "$cur" == "$last" ]] && break
  done
  "$HOME/.config/i3/displays.sh" || true
}

# Outer loop restarts the listener if xev ever exits (e.g. X server restart).
while :; do
  stdbuf -oL xev -root -event randr 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      *RRScreenChangeNotify*|*OutputChange*|*CrtcChange*)
        date +%s%N >"$STAMP"
        settle_and_apply &
        ;;
    esac
  done
  sleep 1
done
