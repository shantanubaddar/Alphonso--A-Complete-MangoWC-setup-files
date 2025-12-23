#!/bin/bash

## Alphonso Autostart Script
## Restores last used theme on login

ALPHONSO_DIR="$HOME/.config/alphonso"
CURRENT_THEME_FILE="$ALPHONSO_DIR/.current-theme"
CURRENT_WALLPAPER_FILE="$ALPHONSO_DIR/.current-wallpaper"

# Get saved theme (default to Alphonso if none exists)
if [ -f "$CURRENT_THEME_FILE" ]; then
    THEME=$(cat "$CURRENT_THEME_FILE")
else
    THEME="Alphonso"
    echo "$THEME" > "$CURRENT_THEME_FILE"
fi

# ===== System services =====
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# ===== Wallpaper daemon =====
swww-daemon &
sleep 0.5

# Restore last wallpaper
if [ -f "$CURRENT_WALLPAPER_FILE" ]; then
    WALLPAPER=$(cat "$CURRENT_WALLPAPER_FILE")
    if [ -f "$WALLPAPER" ]; then
        swww img "$WALLPAPER" --transition-type fade --transition-fps 60 --transition-duration 1 &
    else
        # Fallback to first wallpaper in theme
        WALLPAPER=$(find "$ALPHONSO_DIR/wallpapers/$THEME" -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -n 1)
        [ -n "$WALLPAPER" ] && swww img "$WALLPAPER" &
    fi
else
    # No saved wallpaper, use first one from theme
    WALLPAPER=$(find "$ALPHONSO_DIR/wallpapers/$THEME" -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -n 1)
    [ -n "$WALLPAPER" ] && swww img "$WALLPAPER" &
fi

# ===== Waybar with saved theme =====
if [ -f "$ALPHONSO_DIR/waybar/themes/$THEME/style.css" ]; then
    waybar -s "$ALPHONSO_DIR/waybar/themes/$THEME/style.css" >/dev/null 2>&1 &
else
    # Fallback to default Alphonso theme
    waybar -s "$ALPHONSO_DIR/waybar/themes/Alphonso/style.css" >/dev/null 2>&1 &
fi

# ===== Other autostart items =====
# Add your other autostart programs here
# Example:
# dunst &
# nm-applet &