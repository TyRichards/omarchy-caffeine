#!/bin/bash
# Link this plugin into Omarchy and put the widget in the bar.
set -euo pipefail

ID="io.github.tyrichards.rabbit"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/omarchy/plugins/$ID"

mkdir -p "$(dirname "$DEST")"
if [[ -e $DEST && ! -L $DEST ]]; then
  echo "$DEST exists and is not a symlink; remove it first." >&2
  exit 1
fi
ln -sfn "$SRC" "$DEST"
chmod +x "$SRC/bin/omarchy-rabbit"

omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
placement=(--section right)
if omarchy plugin list 2>/dev/null | grep -q '^omarchy.agents .*enabled'; then
  placement+=(--before omarchy.agents)
fi
omarchy plugin enable "$ID" "${placement[@]}"
echo "Rabbit installed. Click the rabbit in the bar, or run: $SRC/bin/omarchy-rabbit toggle"
