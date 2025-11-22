#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS_IMAGE="$ROOT_DIR/img/gossip_status.jpg"

usage() {
  cat <<'EOF'
Usage:
  scripts/update_status_image_file.sh <source_image>

Copies the source image to img/gossip_status.jpg and updates the status.
The source image can be:
  - A relative path from project root (e.g., img/photo.jpg)
  - An absolute path

Examples:
  scripts/update_status_image_file.sh img/photo.jpg
  scripts/update_status_image_file.sh /path/to/image.png
EOF
}

if [[ $# -lt 1 ]]; then
  echo "Error: source image path is required." >&2
  usage
  exit 1
fi

source_image="$1"

# Check if source file exists
if [[ ! -f "$ROOT_DIR/$source_image" && ! -f "$source_image" ]]; then
  echo "Error: Source image file not found: $source_image" >&2
  exit 1
fi

# Determine the actual source path
if [[ -f "$ROOT_DIR/$source_image" ]]; then
  actual_source="$ROOT_DIR/$source_image"
elif [[ -f "$source_image" ]]; then
  actual_source="$source_image"
fi

# Copy the image
cp "$actual_source" "$STATUS_IMAGE"

# Update the status file to use the fixed path
"$ROOT_DIR/scripts/update_status_image.sh" "img/gossip_status.jpg"

echo "Updated status image:"
echo "  Source: $source_image"
echo "  Destination: img/gossip_status.jpg"
echo "  Status updated to use: img/gossip_status.jpg"

