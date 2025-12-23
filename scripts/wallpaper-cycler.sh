#!/usr/bin/env bash

## Alphonso Wallpaper Cycler
## Cycles through wallpapers in the current theme

ALPHONSO_DIR="$HOME/.config/alphonso"
CURRENT_THEME_FILE="$ALPHONSO_DIR/.current-theme"
CURRENT_WALLPAPER_FILE="$ALPHONSO_DIR/.current-wallpaper"

# Get current theme
if [ -f "$CURRENT_THEME_FILE" ]; then
    theme=$(cat "$CURRENT_THEME_FILE")
else
    theme="Alphonso"  # Default
fi

WALLPAPER_DIR="$ALPHONSO_DIR/wallpapers/$theme"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Alphonso" "No wallpapers found for $theme theme" -t 2000
    exit 1
fi

# Get all wallpapers in the theme directory
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort)

# Check if any wallpapers exist
if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "Alphonso" "No wallpapers found in $theme" -t 2000
    exit 1
fi

# Get current wallpaper index
current_wallpaper=""
current_index=0

if [ -f "$CURRENT_WALLPAPER_FILE" ]; then
    current_wallpaper=$(cat "$CURRENT_WALLPAPER_FILE")
    
    # Find index of current wallpaper
    for i in "${!wallpapers[@]}"; do
        if [ "${wallpapers[$i]}" = "$current_wallpaper" ]; then
            current_index=$i
            break
        fi
    done
fi

# Calculate next wallpaper index (cycle through)
next_index=$(( (current_index + 1) % ${#wallpapers[@]} ))
next_wallpaper="${wallpapers[$next_index]}"

# Set the wallpaper
if command -v swww &> /dev/null; then
    # Ensure swww-daemon is running
    if ! pgrep -x swww-daemon > /dev/null; then
        echo "⚠ swww-daemon not running, restarting..."
        swww-daemon &
        sleep 1
    fi
    
    # Debug output
    echo "DEBUG: Theme: $theme" >> /tmp/alphonso-wallpaper.log
    echo "DEBUG: Switching to: $next_wallpaper" >> /tmp/alphonso-wallpaper.log
    echo "DEBUG: Index: $next_index / ${#wallpapers[@]}" >> /tmp/alphonso-wallpaper.log
    
    # Use swww if available (faster, smoother transitions)
    if swww img "$next_wallpaper" --transition-type fade --transition-fps 60 --transition-duration 1; then
        echo "DEBUG: swww command succeeded" >> /tmp/alphonso-wallpaper.log
    else
        echo "DEBUG: swww command failed with code $?" >> /tmp/alphonso-wallpaper.log
        notify-send "Alphonso" "Failed to set wallpaper" -t 2000
        exit 1
    fi
elif command -v swaybg &> /dev/null; then
    # Kill ALL swaybg instances (waypaper might have spawned multiple)
    killall swaybg 2>/dev/null
    sleep 0.1
    # Start new swaybg
    swaybg -i "$next_wallpaper" -m fill >/dev/null 2>&1 &
    disown
elif command -v hyprpaper &> /dev/null; then
    # Use hyprpaper (for Hyprland users who might be testing)
    hyprctl hyprpaper preload "$next_wallpaper"
    hyprctl hyprpaper wallpaper ",$next_wallpaper"
else
    notify-send "Alphonso" "No wallpaper setter found (install swww or swaybg)" -t 3000
    exit 1
fi

# Save current wallpaper
echo "$next_wallpaper" > "$CURRENT_WALLPAPER_FILE"

# Get wallpaper filename for notification
wallpaper_name=$(basename "$next_wallpaper")

# Send notification
if command -v notify-send &> /dev/null; then
    notify-send "Alphonso Wallpaper" "$wallpaper_name (${next_index}/${#wallpapers[@]})" -t 2000
fi

echo "Wallpaper changed to: $wallpaper_name"