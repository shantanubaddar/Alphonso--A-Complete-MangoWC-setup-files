#!/usr/bin/env bash

## Alphonso Power Menu
## Always uses the current theme

ALPHONSO_DIR="$HOME/.config/alphonso"
CURRENT_THEME_FILE="$ALPHONSO_DIR/.current-theme"

# Get current theme
if [ -f "$CURRENT_THEME_FILE" ]; then
    theme=$(cat "$CURRENT_THEME_FILE")
else
    theme="Alphonso"  # Default
fi

# Run the theme-specific power menu script
bash "$ALPHONSO_DIR/rofi/$theme/powermenu.sh"