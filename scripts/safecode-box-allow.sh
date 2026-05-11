#!/bin/bash
set -e

# Target the persistent config in the volume
CONFIG_FILE="/root/.local/share/opencode/opencode.json"

if [ -z "$1" ]; then
    echo "Usage: safecode-box-allow <provider-id>"
    echo "Example: safecode-box-allow openai"
    exit 1
fi

PROVIDER=$1

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    echo "Please launch SafeCode-Box once to initialize the config."
    exit 1
fi

# Add provider to enabled_providers if not already present
# This edits the file in the persistent volume
jq --arg p "$PROVIDER" '.enabled_providers = (.enabled_providers + [$p] | unique)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

echo "✅ Provider '$PROVIDER' has been added to the allow-list in your persistent volume."
