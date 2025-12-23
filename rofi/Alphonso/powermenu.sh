#!/usr/bin/env bash

## Power menu script for Alphonso

# Options with text icons
shutdown="⏻"
reboot="↻"
lock="🔒"
suspend="⏾"
logout="⎋"

# Rofi command
rofi_cmd() {
    rofi -dmenu \
        -p "Power Menu" \
        -theme ~/.config/alphonso/rofi/Alphonso/powermenu.rasi
}

# Show menu
chosen="$(echo -e "$lock\n$logout\n$suspend\n$reboot\n$shutdown" | rofi_cmd)"

# Execute command
case $chosen in
    $shutdown)
        systemctl poweroff
        ;;
    $reboot)
        systemctl reboot
        ;;
    $lock)
        hyprlock  # or your lock command
        ;;
    $suspend)
        systemctl suspend
        ;;
    $logout)
        # For MangoWC, adjust this command
        mangowc -exit
        ;;
esac