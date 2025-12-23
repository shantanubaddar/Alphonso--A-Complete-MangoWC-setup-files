#!/usr/bin/env bash

# Alphonso v1.0 Installation Script
# Opinionated MangoWC setup with 5 beautiful themes

set -e  # Exit on error

ALPHONSO_DIR="$HOME/.config/alphonso"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

# Check if running Arch-based distro
check_distro() {
    if [ ! -f /etc/arch-release ] && [ ! -f /etc/artix-release ]; then
        print_warning "This installer is designed for Arch-based distributions."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Check for required dependencies
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing_deps=()
    local required_deps=(
        "mangowc"
        "waybar"
        "rofi"
        "ghostty"
        "btop"
        "swww"
        "hyprlock"
    )
    
    for dep in "${required_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
            print_error "$dep is not installed"
        else
            print_success "$dep is installed"
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        echo
        read -p "Would you like to install missing dependencies? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_dependencies "${missing_deps[@]}"
        else
            print_error "Cannot continue without required dependencies"
            exit 1
        fi
    fi
}

# Install missing dependencies
install_dependencies() {
    print_info "Installing dependencies..."
    
    # Check if yay is available
    if command -v yay &> /dev/null; then
        yay -S --needed "$@"
    elif command -v paru &> /dev/null; then
        paru -S --needed "$@"
    else
        print_error "No AUR helper found. Please install yay or paru first."
        exit 1
    fi
}

# Backup existing configs
backup_configs() {
    print_header "Backing Up Existing Configs"
    
    local backup_dir="$HOME/.config/alphonso-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    local configs_to_backup=(
        "$HOME/.config/waybar"
        "$HOME/.config/rofi"
        "$HOME/.config/ghostty"
        "$HOME/.config/btop"
        "$HOME/.config/hypr/hyprlock.conf"
        "$HOME/.config/gtk-3.0/gtk.css"
        "$HOME/.config/gtk-4.0/gtk.css"
    )
    
    for config in "${configs_to_backup[@]}"; do
        if [ -e "$config" ]; then
            print_info "Backing up $(basename "$config")..."
            cp -r "$config" "$backup_dir/" 2>/dev/null || true
        fi
    done
    
    print_success "Backups saved to: $backup_dir"
}

# Install Alphonso configs
install_configs() {
    print_header "Installing Alphonso Configs"
    
    # Create main directory
    mkdir -p "$ALPHONSO_DIR"
    
    # Copy all config directories
    print_info "Copying configuration files..."
    cp -r "$REPO_DIR/waybar" "$ALPHONSO_DIR/"
    cp -r "$REPO_DIR/rofi" "$ALPHONSO_DIR/"
    cp -r "$REPO_DIR/Hyprlock" "$ALPHONSO_DIR/"
    cp -r "$REPO_DIR/wallpapers" "$ALPHONSO_DIR/"
    cp -r "$REPO_DIR/ghostty" "$ALPHONSO_DIR/"
    cp -r "$REPO_DIR/btop" "$ALPHONSO_DIR/"
    cp -r "$REPO_DIR/gtk" "$ALPHONSO_DIR/"
    cp -r "$REPO_DIR/scripts" "$ALPHONSO_DIR/"
    
    # Copy MangoWC config
    cp "$REPO_DIR/config.conf" "$ALPHONSO_DIR/"
    cp "$REPO_DIR/autostart.sh" "$ALPHONSO_DIR/"
    
    # Make scripts executable
    chmod +x "$ALPHONSO_DIR/scripts/"*.sh
    chmod +x "$ALPHONSO_DIR/autostart.sh"
    
    print_success "Configuration files installed"
}

# Set up symlinks
setup_symlinks() {
    print_header "Setting Up Symlinks"
    
    # Waybar - link to default config location
    if [ ! -L "$HOME/.config/waybar" ]; then
        rm -rf "$HOME/.config/waybar"
        ln -s "$ALPHONSO_DIR/waybar" "$HOME/.config/waybar"
        print_success "Waybar symlink created"
    fi
    
    # Ghostty config
    mkdir -p "$HOME/.config/ghostty"
    ln -sf "$ALPHONSO_DIR/ghostty/config" "$HOME/.config/ghostty/config"
    print_success "Ghostty config linked"
    
    # btop themes
    mkdir -p "$HOME/.config/btop"
    if [ ! -L "$HOME/.config/btop/themes" ]; then
        rm -rf "$HOME/.config/btop/themes"
        ln -s "$ALPHONSO_DIR/btop/themes" "$HOME/.config/btop/themes"
        print_success "btop themes linked"
    fi
    
    # MangoWC config
    mkdir -p "$HOME/.config/mango"
    ln -sf "$ALPHONSO_DIR/config.conf" "$HOME/.config/mango/config.conf"
    ln -sf "$ALPHONSO_DIR/autostart.sh" "$HOME/.config/mango/autostart.sh"
    print_success "MangoWC config linked"
}

# Set default theme
set_default_theme() {
    print_header "Setting Default Theme"
    
    echo "Available themes:"
    echo "  1) Alphonso (bright yellow + orange)"
    echo "  2) Blush-Alphonso (pink + red)"
    echo "  3) Kesar (golden + green)"
    echo "  4) Marshland (olive + bright green)"
    echo "  5) Palmer (crimson + yellow)"
    echo
    
    read -p "Select default theme (1-5) [1]: " theme_choice
    theme_choice=${theme_choice:-1}
    
    case $theme_choice in
        1) THEME="Alphonso" ;;
        2) THEME="Blush-Alphonso" ;;
        3) THEME="Kesar" ;;
        4) THEME="Marshland" ;;
        5) THEME="Palmer" ;;
        *) THEME="Alphonso" ;;
    esac
    
    # Save current theme
    echo "$THEME" > "$ALPHONSO_DIR/.current-theme"
    
    # Apply theme
    print_info "Applying $THEME theme..."
    
    # Set Rofi
    rm -f "$HOME/.config/rofi"
    ln -sf "$ALPHONSO_DIR/rofi/$THEME" "$HOME/.config/rofi"
    
    # Set Hyprlock
    ln -sf "$ALPHONSO_DIR/Hyprlock/$THEME/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
    
    # Set GTK
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    ln -sf "$ALPHONSO_DIR/gtk/$THEME/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
    ln -sf "$ALPHONSO_DIR/gtk/$THEME/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
    
    # Set btop theme
    if [ -f "$HOME/.config/btop/btop.conf" ]; then
        sed -i "s|^color_theme.*|color_theme = \"$ALPHONSO_DIR/btop/themes/$THEME\"|" "$HOME/.config/btop/btop.conf"
    else
        echo "color_theme = \"$ALPHONSO_DIR/btop/themes/$THEME\"" > "$HOME/.config/btop/btop.conf"
    fi
    
    # Set wallpaper
    WALLPAPER=$(find "$ALPHONSO_DIR/wallpapers/$THEME" -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -n 1)
    echo "$WALLPAPER" > "$ALPHONSO_DIR/.current-wallpaper"
    
    print_success "Default theme set to: $THEME"
}

# Post-installation instructions
post_install() {
    print_header "Installation Complete!"
    
    echo
    print_success "Alphonso has been installed successfully!"
    echo
    echo "Next steps:"
    echo "  1. Log out and select 'MangoWC' at your login screen"
    echo "  2. Or reload MangoWC config: mangowc --reload-config"
    echo
    echo "Keybindings:"
    echo "  Super + Shift + T : Switch theme"
    echo "  Super + W         : Cycle wallpaper"
    echo "  Super + R         : App launcher"
    echo "  Super + Escape    : Power menu"
    echo
    echo "Config location: $ALPHONSO_DIR"
    echo "Backup location: Check ~/.config/alphonso-backup-*"
    echo
    print_info "Enjoy Alphonso! 🥭"
}

# Main installation flow
main() {
    clear
    print_header "Alphonso v1.0 Installer"
    echo
    echo "This script will install Alphonso - an opinionated MangoWC setup"
    echo "with 5 beautiful, coordinated themes."
    echo
    read -p "Continue with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    
    check_distro
    check_dependencies
    backup_configs
    install_configs
    setup_symlinks
    set_default_theme
    post_install
}

# Run main installation
main
