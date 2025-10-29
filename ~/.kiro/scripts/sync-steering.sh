#!/bin/bash

# Sync central steering files to current workspace
# Usage: sync-steering.sh [workspace-path]

CENTRAL_STEERING="$HOME/.kiro/steering"
WORKSPACE_PATH="${1:-.}"
WORKSPACE_STEERING="$WORKSPACE_PATH/.kiro/steering"

# Create workspace steering directory if it doesn't exist
mkdir -p "$WORKSPACE_STEERING"

# Copy all steering files from central location
if [ -d "$CENTRAL_STEERING" ]; then
    echo "Syncing steering files to $WORKSPACE_STEERING..."
    cp -v "$CENTRAL_STEERING"/*.md "$WORKSPACE_STEERING/" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✓ Steering files synced successfully"
    else
        echo "⚠ No steering files found in $CENTRAL_STEERING"
    fi
else
    echo "✗ Central steering directory not found: $CENTRAL_STEERING"
    exit 1
fi
