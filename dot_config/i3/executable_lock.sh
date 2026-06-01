#!/usr/bin/env bash
set -euo pipefail

SRC="$HOME/Wallpaper/lock.png"
CACHE_DIR="$HOME/.cache/i3lock"
mkdir -p "$CACHE_DIR"

res=$(xrandr --query | awk '/ connected primary/{for(i=3;i<=NF;i++) if ($i ~ /^[0-9]+x[0-9]+\+/){split($i,a,"+"); print a[1]; exit}}')
[[ -z "$res" ]] && res=$(xrandr --query | awk '/ connected/{for(i=2;i<=NF;i++) if ($i ~ /^[0-9]+x[0-9]+\+/){split($i,a,"+"); print a[1]; exit}}')

mtime=$(stat -c %Y "$SRC")
cache="$CACHE_DIR/lock-${res}-${mtime}.png"

if [[ ! -f "$cache" ]]; then
  python3 - "$SRC" "$cache" "$res" <<'PY'
import sys
from PIL import Image
src, dst, res = sys.argv[1], sys.argv[2], sys.argv[3]
w, h = map(int, res.split('x'))
img = Image.open(src).convert('RGB')
sw, sh = img.size
scale = max(w / sw, h / sh)
nw, nh = int(sw * scale), int(sh * scale)
img = img.resize((nw, nh), Image.LANCZOS)
left = (nw - w) // 2
top = (nh - h) // 2
img.crop((left, top, left + w, top + h)).save(dst, 'PNG')
PY
fi

exec i3lock -i "$cache" "$@"
