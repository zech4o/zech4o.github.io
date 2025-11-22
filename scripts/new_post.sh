#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POSTS_DIR="$ROOT_DIR/_posts"
mkdir -p "$POSTS_DIR"

usage() {
  cat <<'EOF'
Usage:
  scripts/new_post.sh ["-c learning|gossip"] ["-s mainline|sideline"] "Post Title" [slug]

Creates a new Jekyll post in _posts/ with today's date. The slug is derived
from the title when omitted. Refuses to overwrite existing posts. Use -c or
--category to choose between learning and gossip categories (default: learning).
Use -s or --subcategory to choose between mainline and sideline for gossip posts.
EOF
}

category=""
subcategory=""
positional=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--category)
      if [[ $# -lt 2 ]]; then
        echo "Error: --category requires a value." >&2
        usage
        exit 1
      fi
      category="$2"
      shift 2
      ;;
    -s|--subcategory)
      if [[ $# -lt 2 ]]; then
        echo "Error: --subcategory requires a value." >&2
        usage
        exit 1
      fi
      subcategory="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      positional+=("$1")
      shift
      ;;
  esac
done

if [[ ${#positional[@]} -lt 1 || ${#positional[@]} -gt 2 ]]; then
  usage
  exit 1
fi

title="${positional[0]}"
slug="${positional[1]:-}"

if [[ -z "$category" ]]; then
  category="learning"
fi

category="$(echo "$category" | tr '[:upper:]' '[:lower:]')"
if [[ "$category" == "chat" ]]; then
  category="gossip"
fi

if [[ "$category" != "learning" && "$category" != "gossip" ]]; then
  echo "Error: category must be 'learning' or 'gossip'." >&2
  exit 1
fi

if [[ -n "$subcategory" ]]; then
  if [[ "$category" != "gossip" ]]; then
    echo "Error: subcategory can only be used with 'gossip' category." >&2
    exit 1
  fi
  subcategory="$(echo "$subcategory" | tr '[:upper:]' '[:lower:]')"
  if [[ "$subcategory" != "mainline" && "$subcategory" != "sideline" ]]; then
    echo "Error: subcategory must be 'mainline' or 'sideline'." >&2
    exit 1
  fi
fi

if [[ -z "$slug" ]]; then
  # Normalize title into a URL-friendly slug
  slug="$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"
fi

if [[ -z "$slug" ]]; then
  slug="post"
fi

date_prefix="$(date +"%Y-%m-%d")"
time_suffix="$(date +"%H:%M:%S %z")"
filename="${date_prefix}-${slug}.md"
filepath="$POSTS_DIR/$filename"

if [[ -e "$filepath" ]]; then
  echo "Error: $filepath already exists." >&2
  exit 1
fi

if [[ -n "$subcategory" ]]; then
cat <<EOF >"$filepath"
---
layout: post
title: "$title"
date: ${date_prefix} ${time_suffix}
category: ${category}
subcategory: ${subcategory}
---

Write your content here.
EOF
else
cat <<EOF >"$filepath"
---
layout: post
title: "$title"
date: ${date_prefix} ${time_suffix}
category: ${category}
---

Write your content here.
EOF
fi

echo "Created $filepath"

