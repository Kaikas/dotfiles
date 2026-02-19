#!/usr/bin/env bash
set -euo pipefail

ICON="󰢮"

if ! command -v sensors >/dev/null 2>&1; then
  echo "${ICON} --°C"
  exit 0
fi

temp=""

# --- Preferred path: sensors -j + jq (robust autodetect) ---
if command -v jq >/dev/null 2>&1 && sensors -j >/dev/null 2>&1; then
  temp="$(
    sensors -j \
    | jq -r '
        # Prefer chips whose key looks like amdgpu*
        (to_entries
          | map(select(.key|test("amdgpu"; "i")))
          | .[]
          | .value
          | .. | objects
          | .temp1_input?, .edge_input?, .junction_input?, .mem_input?
          | select(type=="number")
        ) // empty
      ' \
    | head -n1
  )"

  # If nothing found under amdgpu*, take first numeric temp*_input anywhere
  if [[ -z "${temp}" || "${temp}" == "null" ]]; then
    temp="$(
      sensors -j \
      | jq -r '
          (.. | objects
            | to_entries[]
            | select(.key|test("temp[0-9]+_input$"))
            | .value
            | select(type=="number")
          ) // empty
        ' \
      | head -n1
    )"
  fi
fi

# --- Fallback path: plain text parsing ---
if [[ -z "${temp}" || "${temp}" == "null" ]]; then
  # Try explicit amdgpu chip blocks first
  temp="$(
    sensors 2>/dev/null \
    | awk '
        BEGIN{in_amdgpu=0}
        /^[^[:space:]].*amdgpu/ {in_amdgpu=1}
        /^[^[:space:]]/ && $0 !~ /amdgpu/ {in_amdgpu=0}
        in_amdgpu && /°C/ {
          v=$2; gsub(/\+|°C/,"",v); print v; exit
        }
      '
  )"
fi

if [[ -z "${temp}" || "${temp}" == "null" ]]; then
  echo "${ICON} --°C"
  exit 0
fi

# Round safely (force C locale; avoid octal nonsense)
t_int="$(LC_ALL=C printf "%.0f" "${temp}")"
echo "${ICON} ${t_int}°C"

