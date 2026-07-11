#!/bin/sh
# Builds the Lazarus/FPC port on macOS (primary target). See CLAUDE.md.
set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

if command -v lazbuild >/dev/null 2>&1; then
    LAZBUILD=lazbuild
elif [ -x /Applications/lazarus/lazbuild ]; then
    LAZBUILD=/Applications/lazarus/lazbuild
else
    echo "error: lazbuild not found (checked PATH and /Applications/lazarus/lazbuild)" >&2
    exit 1
fi

"$LAZBUILD" Starter.lpi

DEST="$SCRIPT_DIR/../pctga/AlfaStarter"
cp "$SCRIPT_DIR/Starter" "$DEST"

echo "Built: $SCRIPT_DIR/Starter"
echo "Copied to: $DEST"
