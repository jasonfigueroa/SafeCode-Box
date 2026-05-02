#!/bin/bash
set -e

CONFIG_DIR="/root/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.json"
TEMPLATE_DIR="/usr/local/share/safecode-box"

mkdir -p "$CONFIG_DIR"

if [ "$BOX_MODE" = "PERSONAL" ]; then
    echo "🔓 Launching in PERSONAL mode (Free models allowed)..."
    cp "$TEMPLATE_DIR/personal-template.json" "$CONFIG_FILE"
else
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "🛡️ First run: Applying Default-Deny Corporate Policy..."
        cp "$TEMPLATE_DIR/corporate-template.json" "$CONFIG_FILE"
    else
        echo "🛡️ Launching in CORPORATE mode (Locked)..."
    fi
fi

# Execute the original command
exec /usr/local/lib/node_modules/opencode-ai/bin/.opencode "$@"
