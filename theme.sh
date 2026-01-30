#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 harpertoken
# Repository: https://github.com/harpertoken

SETTINGS_PATH="$HOME/Library/Application Support/Code/User/settings.json"
THEME_MARKER="# harpertoken-black-theme-applied"

# Security: Validate settings path
if [[ ! "$SETTINGS_PATH" =~ ^/Users/[^/]+/Library/Application\ Support/Code/User/settings\.json$ ]]; then
  echo "Error: Invalid settings path"
  exit 1
fi

# Security: Check if VS Code directory exists
if [[ ! -d "$(dirname "$SETTINGS_PATH")" ]]; then
  echo "Error: VS Code settings directory not found"
  exit 1
fi

case "${1:-toggle}" in
  "apply"|"on")
    if grep -q "$THEME_MARKER" "$SETTINGS_PATH" 2>/dev/null; then
      echo "Black theme already applied!"
      exit 0
    fi
    
    # Backup and apply
    cp "$SETTINGS_PATH" "$SETTINGS_PATH.backup" 2>/dev/null
    
    THEME_CONFIG='{
      "workbench.colorCustomizations": {
        "editor.background": "#0a0a0a",
        "editor.foreground": "#cccccc",
        "activityBar.background": "#1a1a1a",
        "sideBar.background": "#151515",
        "statusBar.background": "#000000"
      }
    }'
    
    if [ -f "$SETTINGS_PATH" ]; then
      echo "$THEME_CONFIG" | jq -s --argjson existing "$(cat "$SETTINGS_PATH")" '$existing * .[0]' > "$SETTINGS_PATH.tmp"
      mv "$SETTINGS_PATH.tmp" "$SETTINGS_PATH"
    else
      echo "$THEME_CONFIG" | jq '.' > "$SETTINGS_PATH"
    fi
    
    echo "$THEME_MARKER" >> "$SETTINGS_PATH"
    echo "✓ Black theme applied!"
    ;;
    
  "undo"|"off")
    if [ -f "$SETTINGS_PATH.backup" ]; then
      cp "$SETTINGS_PATH.backup" "$SETTINGS_PATH"
      echo "✓ Theme reverted!"
    else
      echo "✗ No backup found"
    fi
    ;;
    
  "toggle")
    if grep -q "$THEME_MARKER" "$SETTINGS_PATH" 2>/dev/null; then
      $0 off
    else
      $0 on
    fi
    ;;
    
  "status")
    if grep -q "$THEME_MARKER" "$SETTINGS_PATH" 2>/dev/null; then
      echo "Black theme: ON"
    else
      echo "Black theme: OFF"
    fi
    ;;
    
  *)
    echo "Usage: $0 [apply|undo|toggle|status]"
    echo "  apply/on   - Apply black theme"
    echo "  undo/off   - Revert to backup"
    echo "  toggle     - Switch theme state (default)"
    echo "  status     - Check current state"
    ;;
esac
