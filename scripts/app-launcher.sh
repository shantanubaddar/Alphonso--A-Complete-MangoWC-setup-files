#!/usr/bin/env bash

## Alphonso App Launcher
## Always uses the current theme

ALPHONSO_DIR="$HOME/.config/alphonso"
CURRENT_THEME_FILE="$ALPHONSO_DIR/.current-theme"

# Get current theme
if [ -f "$CURRENT_THEME_FILE" ]; then
    theme=$(cat "$CURRENT_THEME_FILE")
else
    theme="Alphonso"  # Default
fi

# Launch rofi with current theme config
rofi -show drun -theme "$ALPHONSO_DIR/rofi/$theme/config.rasi"
