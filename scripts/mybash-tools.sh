#!/bin/bash

# MyBash Tools - Interactive tool reference
# Uses glow for pretty rendering if available

TOOLS_FILE="$HOME/.local/share/mybash/TOOLS.md"

# Fallback to repo location if not installed
if [ ! -f "$TOOLS_FILE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TOOLS_FILE="$(dirname "$SCRIPT_DIR")/docs/TOOLS.md"
fi

if [ ! -f "$TOOLS_FILE" ]; then
    echo "Error: TOOLS.md not found"
    exit 1
fi

# Use glow if available for pretty rendering
if command -v glow &> /dev/null; then
    glow "$TOOLS_FILE"
else
    # Fallback to bat with less for pagination
    if command -v bat &> /dev/null; then
        bat --style=plain "$TOOLS_FILE"
    else
        less "$TOOLS_FILE"
    fi
fi
