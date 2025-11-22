#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS_FILE="$ROOT_DIR/_data/gossip_status.yml"
IMG_DIR="$ROOT_DIR/img"

usage() {
  cat <<'EOF'
Usage:
  scripts/update_status_image.sh [image_path]

Updates the gossip status image. 
- If no argument is provided, uses the fixed image file: img/gossip_status.jpg
- If image_path is provided, it can be:
  - A relative path from project root (e.g., img/photo.jpg)
  - An absolute path
  - An empty string "" to remove the image

Examples:
  scripts/update_status_image.sh                    # Use img/gossip_status.jpg
  scripts/update_status_image.sh img/photo.jpg      # Use specific image
  scripts/update_status_image.sh ""                 # Remove image

Note: To update the actual image file, use:
  scripts/update_status_image_file.sh <source_image>
EOF
}

# Default to fixed image file if no argument provided
if [[ $# -lt 1 ]]; then
  image_path="img/gossip_status.jpg"
  echo "No image path provided, using default: $image_path"
else
  image_path="$1"
fi

# If empty string, remove image
if [[ -z "$image_path" || "$image_path" == '""' ]]; then
  image_path=""
else
  # Check if file exists
  if [[ ! -f "$ROOT_DIR/$image_path" && ! -f "$image_path" ]]; then
    echo "Warning: Image file not found: $image_path" >&2
    echo "Continuing anyway..." >&2
  fi
  
  # If it's an absolute path, make it relative to site root
  if [[ "$image_path" == /* ]]; then
    # Try to make it relative to img directory
    if [[ "$image_path" == *"$IMG_DIR"* ]]; then
      image_path="${image_path#$ROOT_DIR/}"
    else
      echo "Warning: Using absolute path. Consider moving image to img/ directory." >&2
      image_path="${image_path#$ROOT_DIR/}"
    fi
  fi
fi

# Read existing status
if [[ -f "$STATUS_FILE" ]]; then
  # Extract text content (everything after "text: |" until "date:")
  # Remove leading 2 spaces (YAML indentation) from each line
  existing_text=$(awk '/^text: \|$/,/^date:/ {if (!/^text: \|/ && !/^date:/) print}' "$STATUS_FILE" | sed 's/^  //')
  existing_date=$(grep "^date:" "$STATUS_FILE" | cut -d'"' -f2)
else
  existing_text=""
  existing_date="$(date +"%Y-%m-%d")"
fi

# Write updated status with proper YAML indentation
cat >"$STATUS_FILE" <<EOF
text: |
  $existing_text
date: "$existing_date"
image: "$image_path"
EOF

if [[ -z "$image_path" ]]; then
  echo "Removed gossip status image"
else
  echo "Updated gossip status image:"
  echo "  Image: $image_path"
  echo "  File: $STATUS_FILE"
fi

