#!/bin/bash
set -euo pipefail
ID="io.github.tyrichards.rabbit"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SRC/bin/omarchy-rabbit" off >/dev/null 2>&1 || true
omarchy plugin disable "$ID" >/dev/null 2>&1 || true
rm -f "$HOME/.config/omarchy/plugins/$ID"
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
echo "Rabbit removed."
