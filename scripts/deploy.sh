#!/usr/bin/env sh

# Usage:
#   deploy.sh [SRC_DIR] [SITE_DIR] [BACKUP_DIR]
SRC_DIR="${1:-.}"
SITE_DIR="${2:-/var/www/devops-site}"
BACKUP_DIR="${3:-backups}"

# files to deploy
INDEX_FILE="$SRC_DIR/index.html"
HEALTH_FILE="$SRC_DIR/health.html"

if [ ! -f "$INDEX_FILE" ] || [ ! -f "$HEALTH_FILE" ]; then
  echo "ERROR: index.html/health.html not found in $SRC_DIR" >&2
  exit 1
fi

if [ ! -d "$SITE_DIR" ]; then
  echo "ERROR: site dir not found: $SITE_DIR" >&2
  exit 1
fi

# 1) backup before deploy (best practice)
if [ -x "$SRC_DIR/scripts/backup.sh" ]; then
  "$SRC_DIR/scripts/backup.sh" "$SITE_DIR" "$BACKUP_DIR" || exit 1
else
  echo "ERROR: backup.sh not executable" >&2
  exit 1
fi

# 2) deploy files
cp -f "$INDEX_FILE" "$SITE_DIR/index.html" || exit 1
cp -f "$HEALTH_FILE" "$SITE_DIR/health.html" || exit 1

# 3) set safe perms
chown -R webdeploy:www-data "$SITE_DIR" || exit 1
chmod -R 755 "$SITE_DIR" || exit 1

# 4) validate nginx config and reload
nginx -t || exit 1
systemctl reload nginx || exit 1

# 5) health check (after reload)
if [ -x "$SRC_DIR/scripts/health_check.sh" ]; then
  "$SRC_DIR/scripts/health_check.sh" "https://localhost/health.html" || exit 1
else
  echo "ERROR: health_check.sh not executable" >&2
  exit 1
fi

# 6) version (short git hash if available)
VER="unknown"
if command -v git >/dev/null 2>&1; then
  VER="$(git -C "$SRC_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
fi
echo "Deployed version: $VER"
exit 0
