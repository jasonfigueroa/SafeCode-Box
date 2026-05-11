#!/bin/bash
set -e

# Persistent location in the safecode-data volume
USER_CONFIG_DIR="/root/.local/share/opencode"
USER_CONFIG_FILE="$USER_CONFIG_DIR/opencode.json"

# Authority location (Highest priority in OpenCode)
SYSTEM_CONFIG_DIR="/etc/opencode"
SYSTEM_CONFIG_FILE="$SYSTEM_CONFIG_DIR/opencode.json"

# Template location
TEMPLATE_DIR="/usr/local/share/safecode-box"

# 1. Ensure directories exist
mkdir -p "$USER_CONFIG_DIR"
mkdir -p "$SYSTEM_CONFIG_DIR"

# 2. Setup the "Highest Authority" Layer
if [ "$BOX_MODE" = "PERSONAL" ]; then
    echo "🔓 Launching in PERSONAL mode (Free models allowed)..."
    # Remove the system-level lock to allow personal overrides
    rm -f "$SYSTEM_CONFIG_FILE"
    
    # Initialize user config with personal defaults if missing
    if [ ! -f "$USER_CONFIG_FILE" ]; then
        cp "$TEMPLATE_DIR/personal-defaults.json" "$USER_CONFIG_FILE"
    fi
else
    echo "🛡️ Launching in CORPORATE mode (Locked)..."
    # Force the system-level lock (Immutable layer)
    cp "$TEMPLATE_DIR/system-lock.json" "$SYSTEM_CONFIG_FILE"
    
    # Initialize user config with corporate defaults (Default Deny) if missing
    if [ ! -f "$USER_CONFIG_FILE" ]; then
        echo "🛡️ First run: Applying Default-Deny User Policy..."
        cp "$TEMPLATE_DIR/corporate-defaults.json" "$USER_CONFIG_FILE"
    fi
fi

# 3. Tell OpenCode exactly where to find the user settings
export OPENCODE_CONFIG="$USER_CONFIG_FILE"

# Execute the original command
exec /usr/local/lib/node_modules/opencode-ai/bin/.opencode "$@"
