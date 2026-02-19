#!/usr/bin/env bash
set -euo pipefail

# RAM usage in %
used=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')

bars=10
filled=$(( used * bars / 100 ))
empty=$(( bars - filled ))

printf "󰍛 "

for ((i=0; i<filled; i++)); do printf "█"; done
for ((i=0; i<empty; i++)); do printf "░"; done

printf " %d%%" "$used"

