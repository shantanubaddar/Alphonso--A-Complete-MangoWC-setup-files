#!/usr/bin/env bash

## Alphonso Theme Switcher
## Switch between different Alphonso flavors

ALPHONSO_DIR="$HOME/.config/alphonso"
CURRENT_THEME_FILE="$ALPHONSO_DIR/.current-theme"

# Available themes
themes=(
    "🥭 Alphonso"
    "💗 Blush-Alphonso"
    "👑 Kesar"
    "🌿 Marshland"
    "🌺 Palmer"
)

# Theme names without emojis (for file paths)
theme_names=(
    "Alphonso"
    "Blush-Alphonso"
    "Kesar"
    "Marshland"
    "Palmer"
)

# Rofi command
rofi_cmd() {
    rofi -dmenu \
        -p "Select Theme" \
        -theme "$ALPHONSO_DIR/rofi/launcher.rasi" \
        -mesg "Choose your Alphonso flavor"
}

# Show menu and get selection
chosen="$(printf '%s\n' "${themes[@]}" | rofi_cmd)"

# Exit if nothing selected
[ -z "$chosen" ] && exit 0

# Extract theme name (remove emoji)
theme_name=""
case "$chosen" in
    *"Blush-Alphonso"*)
        theme_name="Blush-Alphonso"
        ;;
    *"Alphonso"*)
        theme_name="Alphonso"
        ;;
    *"Kesar"*)
        theme_name="Kesar"
        ;;
    *"Marshland"*)
        theme_name="Marshland"
        ;;
    *"Palmer"*)
        theme_name="Palmer"
        ;;
esac

[ -z "$theme_name" ] && exit 1

# Function to switch theme
switch_theme() {
    local theme=$1
    
    echo "Switching to $theme..."
    
    # 1. Switch Waybar style
    if [ -f "$ALPHONSO_DIR/waybar/themes/$theme/style.css" ]; then
        pkill waybar
        waybar -s "$ALPHONSO_DIR/waybar/themes/$theme/style.css" >/dev/null 2>&1 &
        echo "✓ Waybar switched"
    fi
    
    # 2. Switch Hyprlock config (create symlink)
    if [ -d "$ALPHONSO_DIR/Hyprlock/$theme" ]; then
        ln -sf "$ALPHONSO_DIR/Hyprlock/$theme/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
        echo "✓ Hyprlock config linked"
    fi
    
    # 3. Switch wallpaper using swww
    echo "DEBUG: Checking wallpapers for theme: $theme"
    if [ -d "$ALPHONSO_DIR/wallpapers/$theme" ]; then
        echo "DEBUG: Wallpaper directory exists"
        # Ensure ONLY ONE swww-daemon is running
        if ! pgrep -x swww-daemon > /dev/null; then
            echo "⚠ swww-daemon not running, starting..."
            swww-daemon &
            sleep 0.5
        fi
        
        # Get first wallpaper in the theme directory
        wallpaper=$(find "$ALPHONSO_DIR/wallpapers/$theme" -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -n 1)
        echo "DEBUG: Found wallpaper: $wallpaper"
        if [ -n "$wallpaper" ]; then
            if command -v swww &> /dev/null; then
                echo "DEBUG: Running swww img command..."
                swww img "$wallpaper" --transition-type fade --transition-fps 60 --transition-duration 1
                # Save the wallpaper path
                echo "$wallpaper" > "$ALPHONSO_DIR/.current-wallpaper"
                echo "✓ Wallpaper changed to: $(basename "$wallpaper")"
            else
                echo "⚠ swww not found, wallpaper not changed"
            fi
        else
            echo "⚠ No wallpapers found in $ALPHONSO_DIR/wallpapers/$theme"
        fi
    else
        echo "⚠ Wallpaper directory not found: $ALPHONSO_DIR/wallpapers/$theme"
    fi
    
    # 4. Create symlink for Rofi configs (so launchers use current theme)
    if [ -d "$ALPHONSO_DIR/rofi/$theme" ]; then
        rm -f "$HOME/.config/rofi"
        ln -sf "$ALPHONSO_DIR/rofi/$theme" "$HOME/.config/rofi"
        echo "✓ Rofi theme linked"
    fi
    
    # 5. Switch Ghostty theme
    if [ -f "$ALPHONSO_DIR/ghostty/themes/$theme.conf" ]; then
        # Update the config-file line in base ghostty config
        sed -i "s|config-file = .*|config-file = ~/.config/alphonso/ghostty/themes/$theme.conf|" "$ALPHONSO_DIR/ghostty/config"
        
        # If ghostty is the user's default terminal, they'll see changes on next launch
        # Optionally: Kill and restart ghostty instances (commented out - can be disruptive)
        # pkill ghostty
        
        echo "✓ Ghostty theme updated (restart terminal to see changes)"
    fi
    
    # 6. Switch btop theme
    if [ -f "$ALPHONSO_DIR/btop/themes/$theme.theme" ]; then
        # Ensure btop themes directory exists and is symlinked
        mkdir -p "$HOME/.config/btop"
        
        # Create symlink if it doesn't exist
        if [ ! -L "$HOME/.config/btop/themes" ]; then
            rm -rf "$HOME/.config/btop/themes"
            ln -s "$ALPHONSO_DIR/btop/themes" "$HOME/.config/btop/themes"
        fi
        
        # Update the color_theme in btop.conf (just the theme name, btop finds it in themes/)
        if [ -f "$HOME/.config/btop/btop.conf" ]; then
            sed -i "s|^color_theme.*|color_theme = \"$theme\"|" "$HOME/.config/btop/btop.conf"
        else
            # Create minimal config with just the theme
            echo "color_theme = \"$theme\"" > "$HOME/.config/btop/btop.conf"
        fi
        
        echo "✓ btop theme updated (restart btop to see changes)"
    fi
    
    # 7. Switch GTK theme
    if [ -d "$ALPHONSO_DIR/gtk/$theme" ]; then
        # Apply GTK CSS overrides by setting XDG config
        export GTK_THEME=""
        
        # Link GTK configs for this theme
        mkdir -p "$HOME/.config/gtk-3.0"
        mkdir -p "$HOME/.config/gtk-4.0"
        
        ln -sf "$ALPHONSO_DIR/gtk/$theme/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
        ln -sf "$ALPHONSO_DIR/gtk/$theme/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
        
        echo "✓ GTK theme updated (restart GTK apps to see changes)"
    fi
    
    # 8. Save current theme
    echo "$theme" > "$CURRENT_THEME_FILE"
    
    # Send notification
    if command -v notify-send &> /dev/null; then
        notify-send "Alphonso Theme" "Switched to $theme" -t 2000
    fi
    
    echo "✓ Theme switched to $theme!"
}

# Execute theme switch
switch_theme "$theme_name"