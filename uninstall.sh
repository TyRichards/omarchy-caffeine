#!/bin/bash
set -euo pipefail
ID="io.github.tyrichards.caffeine"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SRC/bin/omarchy-caffeine" off >/dev/null 2>&1 || true
omarchy plugin disable "$ID" >/dev/null 2>&1 || true
rm -f "$HOME/.config/omarchy/plugins/$ID"
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
echo "Caffeine removed."
