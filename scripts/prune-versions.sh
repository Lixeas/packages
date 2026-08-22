#!/usr/bin/env bash
set -euo pipefail
# Usage: prune-versions.sh <dir> <grep-pattern> <keep-count>
DIR="$1"
PATTERN="$2"
KEEP="${3:-5}"

mapfile -t FILES < <(ls -1 "$DIR" 2>/dev/null | grep -E "$PATTERN" | sort -V)
COUNT=${#FILES[@]}
if (( COUNT > KEEP )); then
  TO_DELETE=$(( COUNT - KEEP ))
  for i in $(seq 0 $(( TO_DELETE - 1 ))); do
    echo "pruning ${FILES[$i]}"
    rm -f "$DIR/${FILES[$i]}"
  done
fi
