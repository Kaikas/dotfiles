#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/discord-mic.state"

# Discord Prozess: je nach Package heißt der ggf. "Discord", "discord", "DiscordCanary", "DiscordPTB"
if ! pgrep -x "Discord" >/dev/null \
  && ! pgrep -x "discord" >/dev/null \
  && ! pgrep -x "DiscordCanary" >/dev/null \
  && ! pgrep -x "DiscordPTB" >/dev/null; then
  echo "󰙯 off"
  exit 0
fi

# Default: wenn keine State-Datei da ist, nehme "live" an (wie bisher)
if [[ ! -f "$STATE_FILE" ]]; then
  echo "󰍬 live"
  exit 0
fi

STATE="$(<"$STATE_FILE")"

case "$STATE" in
  muted)
    echo "󰍭 muted"
    ;;
  live)
    echo "󰍬 live"
    ;;
  *)
    echo "󰍬 ?"
    ;;
esac

