#!/usr/bin/env bash
# Single-direction hard sync: source project docs/ → mirror/<project>/
# Any edits in mirror/ will be overwritten on the next sync.
#
# Usage:
#   ./scripts/sync.sh           # sync all projects in vault-config.yml
#
# Requires: rsync, awk, bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG="$SCRIPT_DIR/vault-config.yml"

if [ ! -f "$CONFIG" ]; then
  echo "Error: $CONFIG not found." >&2
  echo "Copy vault-config.example.yml to vault-config.yml and fill in your project paths." >&2
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "Error: rsync not found. Install it (e.g. 'brew install rsync' on macOS)." >&2
  exit 1
fi

# Minimal YAML parse — matches the layout in vault-config.example.yml only.
# Emits one TAB-separated "name<TAB>source" line per project.
parse_config() {
  awk '
    /^[[:space:]]*-[[:space:]]*name:/ {
      sub(/^[[:space:]]*-[[:space:]]*name:[[:space:]]*/, "")
      sub(/[[:space:]]*#.*$/, "")
      name = $0
    }
    /^[[:space:]]*source:/ && name != "" {
      sub(/^[[:space:]]*source:[[:space:]]*/, "")
      sub(/[[:space:]]*#.*$/, "")
      print name "\t" $0
      name = ""
    }
  ' "$CONFIG"
}

count=0
while IFS=$'\t' read -r name source; do
  [ -z "$name" ] && continue
  [ -z "$source" ] && continue

  if [ ! -d "$source" ]; then
    echo "Warning: source for '$name' does not exist: $source (skipping)" >&2
    continue
  fi

  target="$VAULT_ROOT/mirror/$name"
  echo "→ $name: $source → mirror/$name/"
  mkdir -p "$target"
  rsync -a --delete "$source/" "$target/"
  count=$((count + 1))
done < <(parse_config)

if [ "$count" -eq 0 ]; then
  echo "No projects synced. Check scripts/vault-config.yml." >&2
  exit 1
fi

echo
echo "Synced $count project(s). Now tell Claude Code:"
echo "  'mirror/<project>/ is synced, start processing'"
