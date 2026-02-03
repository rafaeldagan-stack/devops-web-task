#!/usr/bin/env sh

SITE_DIR="${1:-/var/www/devops-site}"
BACKUP_DIR="${2:-backups}"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "ERROR: backup dir not found: $BACKUP_DIR" >&2
  exit 1
fi

LATEST="$(ls -1t "$BACKUP_DIR"/site-*.tar.gz 2>/dev/null | head -n 1)"

if [ -z "$LATEST" ]; then
  echo "ERROR: no backups found in $BACKUP_DIR" >&2
  exit 1
fi

if [ ! -d "$SITE_DIR" ]; then
  echo "ERROR: site dir not found: $SITE_DIR" >&2
  exit 1
fi

echo "Rolling back using: $LATEST"

# safety: create temp dir, extract there, then replace content
TMPDIR="$(mktemp -d)"
if [ -z "$TMPDIR" ] || [ ! -d "$TMPDIR" ]; then
  echo "ERROR: failed to create temp dir" >&2
  exit 1
fi

tar -C "$TMPDIR" -xzf "$LATEST" || { rm -rf "$TMPDIR"; exit 1; }

# remove current content safely (keep directory)
rm -rf "$SITE_DIR"/*

# copy restored content
cp -a "$TMPDIR"/. "$SITE_DIR"/ || { rm -rf "$TMPDIR"; exit 1; }

rm -rf "$TMPDIR"

echo "Rollback complete."
exit 0
