#!/bin/bash

#==============================================================================
# KDE Desktop Installation Module
# Parameters: $1=theme, $2=performance_mode
#==============================================================================

THEME="${1:-breeze-dark}"
PERFORMANCE_MODE="${2:-true}"

print_info() {
    echo -e "\033[0;34mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

print_info "Installing KDE Desktop Environment..."

# Update package list
sudo apt update

# Install KDE Desktop
print_info "Installing KDE Plasma desktop packages..."
sudo apt install -y \
    kde-plasma-desktop \
    plasma-workspace \
    sddm \
    kde-standard \
    plasma-discover \
    plasma-nm \
    plasma-pa \
    powerdevil \
    systemsettings \
    dolphin \
    konsole \
    kate \
    kcalc \
    gwenview \
    okular \
    ark \
    kwrite \
    kfind \
    plasma-desktop

# Install additional KDE applications
print_info "Installing additional KDE applications..."
sudo apt install -y \
    firefox \
    libreoffice \
    gimp \
    vlc \
    thunderbird

# Set up display manager
print_info "Configuring display manager..."
sudo systemctl enable sddm

# Apply theme if specified
if [[ "$THEME" == "breeze-dark" ]]; then
    print_info "Setting up Breeze Dark theme..."
    # Theme will be configured per-user later
fi

print_success "KDE Desktop Environment installation completed"
