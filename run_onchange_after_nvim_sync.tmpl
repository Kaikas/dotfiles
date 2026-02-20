#!/usr/bin/env bash
set -euo pipefail

{{- if eq .chezmoi.os "linux" }}

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

{{- if eq .distro "arch" }}
sudo pacman -S --needed --noconfirm \
      neovim xclip

{{- else if eq .distro "ubuntu" }}
sudo apt update
sudo apt install -y \
    xclip neovim

{{- end }}

if command -v nvim >/dev/null 2>&1; then
  echo "Running Neovim plugin sync..."
  nvim --headless "+Lazy! sync" +qa
fi

{{- end }}


