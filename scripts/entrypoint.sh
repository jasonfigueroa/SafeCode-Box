#!/bin/bash
set -e

CONFIG_DIR="/root/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.json"
MODE_FILE="$CONFIG_DIR/.safecode-box-mode"
TEMPLATE_DIR="/usr/local/share/safecode-box"

mkdir -p "$CONFIG_DIR"

apply_corporate_policy() {
    cp "$TEMPLATE_DIR/corporate-template.json" "$CONFIG_FILE"
    printf '%s' "CORPORATE" > "$MODE_FILE"
}

apply_personal_policy() {
    if [ ! -f "$CONFIG_FILE" ] || [ "$(cat "$MODE_FILE" 2>/dev/null || true)" != "PERSONAL" ]; then
        cp "$TEMPLATE_DIR/personal-template.json" "$CONFIG_FILE"
    fi
    printf '%s' "PERSONAL" > "$MODE_FILE"
}

if [ "$BOX_MODE" = "PERSONAL" ]; then
    echo "🔓 Launching in PERSONAL mode (Free models allowed)..."
    apply_personal_policy
else
    if [ ! -f "$CONFIG_FILE" ] || [ "$(cat "$MODE_FILE" 2>/dev/null || true)" != "CORPORATE" ]; then
        echo "🛡️ First run: Applying Default-Deny Corporate Policy..."
        apply_corporate_policy
    else
        echo "🛡️ Launching in CORPORATE mode (Locked)..."
        jq '.share="disabled" | .enabled_providers=[] | .disabled_providers=(.disabled_providers // [] | unique + ["opencode"] | unique)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
fi

if [ "$1" = "safecode-box-allow" ]; then
    shift
    exec /usr/local/bin/safecode-box-allow "$@"
fi

# Execute the original command
exec /usr/local/lib/node_modules/opencode-ai/bin/.opencode "$@"
