#!/bin/bash

#==============================================================================
# Additional Applications Installation Module
#==============================================================================

print_info() {
    echo -e "\033[0;34mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

print_info "Installing additional applications..."

# Development tools
print_info "Installing development tools..."
sudo apt install -y \
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    tree \
    unzip \
    zip

# Media and graphics
print_info "Installing media applications..."
sudo apt install -y \
    vlc \
    gimp \
    inkscape \
    audacity \
    cheese

# Office and productivity
print_info "Installing office applications..."
sudo apt install -y \
    libreoffice \
    thunderbird \
    firefox \
    chromium-browser

# System utilities
print_info "Installing system utilities..."
sudo apt install -y \
    gparted \
    synaptic \
    bleachbit \
    timeshift

# Network tools
print_info "Installing network tools..."
sudo apt install -y \
    net-tools \
    nmap \
    wireshark \
    filezilla

print_success "Additional applications installed"
