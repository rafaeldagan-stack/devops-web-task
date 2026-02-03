#!/usr/bin/env sh

SITE_DIR="${1:-/var/www/devops-site}"
BACKUP_DIR="${2:-backups}"

if [ ! -d "$SITE_DIR" ]; then
  echo "ERROR: site dir not found: $SITE_DIR" >&2
  exit 1
fi

mkdir -p "$BACKUP_DIR" || exit 1

TS="$(date +%Y%m%d-%H%M%S)"
ARCHIVE="$BACKUP_DIR/site-$TS.tar.gz"

# create backup archive
tar -C "$SITE_DIR" -czf "$ARCHIVE" . || exit 1
echo "Created backup: $ARCHIVE"

# keep only last 5 backups (by filename timestamp)
# list newest first, remove from 6th onward
ls -1t "$BACKUP_DIR"/site-*.tar.gz 2>/dev/null | sed -n '6,$p' | while read -r old; do
  rm -f "$old"
  echo "Removed old backup: $old"
done

exit 0
