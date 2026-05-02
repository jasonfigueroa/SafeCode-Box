#!/bin/bash
set -e

CONFIG_FILE="/root/.config/opencode/opencode.json"

if [ -z "$1" ]; then
    echo "Usage: safecode-box-allow <provider-id>"
    echo "Example: safecode-box-allow openai"
    exit 1
fi

PROVIDER=$1

if [ "$BOX_MODE" = "CORPORATE" ] && [ "$PROVIDER" = "opencode" ]; then
    echo "Error: 'opencode' is disabled in CORPORATE mode."
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

# Add provider to enabled_providers if not already present
jq --arg p "$PROVIDER" '.enabled_providers = (.enabled_providers + [$p] | unique)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

echo "✅ Provider '$PROVIDER' has been added to the allow-list."
