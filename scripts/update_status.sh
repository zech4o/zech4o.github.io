#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS_FILE="$ROOT_DIR/_data/gossip_status.yml"

usage() {
  cat <<'EOF'
Usage:
  scripts/update_status.sh "你的动态文本"

Updates the gossip status text with the current date.
EOF
}

if [[ $# -lt 1 ]]; then
  echo "Error: status text is required." >&2
  usage
  exit 1
fi

status_text="$1"
current_date="$(date +"%Y-%m-%d")"

# Read existing image if it exists
if [[ -f "$STATUS_FILE" ]]; then
  existing_image=$(grep "^image:" "$STATUS_FILE" | cut -d'"' -f2)
else
  existing_image=""
fi

# Use YAML literal block scalar for better handling of special characters
cat >"$STATUS_FILE" <<EOF
text: |
  $status_text
date: "$current_date"
image: "$existing_image"
EOF

echo "Updated gossip status:"
echo "  Text: $status_text"
echo "  Date: $current_date"
echo "  File: $STATUS_FILE"

