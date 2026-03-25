#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="${1:-assets/images/equipment_raw}"
OUT_DIR="${2:-assets/images/equipment}"
MAX_PX="${3:-256}"

if ! command -v sips >/dev/null 2>&1; then
  echo "Error: 'sips' not found (required on macOS for resize)." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

shopt -s nullglob
files=("$SRC_DIR"/*.png)
if [ ${#files[@]} -eq 0 ]; then
  echo "No PNG files found in: $SRC_DIR"
  exit 0
fi

echo "Optimizing ${#files[@]} PNG files..."
echo "Source: $SRC_DIR"
echo "Output: $OUT_DIR"
echo "Max size: ${MAX_PX}px"

for src in "${files[@]}"; do
  base="$(basename "$src")"
  tmp="$OUT_DIR/.tmp_$base"
  out="$OUT_DIR/$base"

  # Resize longest side to MAX_PX while preserving aspect ratio.
  sips -s format png -Z "$MAX_PX" "$src" --out "$tmp" >/dev/null

  # Optional aggressive compression if pngquant is installed.
  if command -v pngquant >/dev/null 2>&1; then
    pngquant --force --output "$out" --quality=68-90 -- "$tmp"
    rm -f "$tmp"
  else
    mv "$tmp" "$out"
  fi

  size_kb=$(du -k "$out" | awk '{print $1}')
  echo "  - $base -> ${size_kb}KB"
done

echo "Done."
