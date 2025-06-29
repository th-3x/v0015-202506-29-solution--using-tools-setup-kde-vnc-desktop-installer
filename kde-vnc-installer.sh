#!/bin/bash

#==============================================================================
# KDE Desktop + noVNC One-Click Installer
# Author: Amazon Q Assistant
# Description: Automated installation of optimized KDE desktop with noVNC access
#==============================================================================

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration file
CONFIG_FILE="./kde-vnc-config.conf"

# Default configuration
DEFAULT_VNC_USER="x2"
DEFAULT_VNC_PASSWORD="password123"
DEFAULT_VNC_GEOMETRY="1920x1080"
DEFAULT_VNC_DEPTH="24"
DEFAULT_VNC_PORT="5901"
DEFAULT_NOVNC_PORT="6080"
DEFAULT_THEME="breeze-dark"
DEFAULT_PERFORMANCE_MODE="true"

#==============================================================================
# Utility Functions
#==============================================================================

print_header() {
    echo -e "${BLUE}"
    echo "=============================================================================="
    echo "$1"
    echo "=============================================================================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

#==============================================================================
# Configuration Management
#==============================================================================

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        print_info "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        print_warning "Configuration file not found. Using defaults."
        create_default_config
    fi
    
    # Set variables with defaults if not defined
    VNC_USER="${VNC_USER:-$DEFAULT_VNC_USER}"
    VNC_PASSWORD="${VNC_PASSWORD:-$DEFAULT_VNC_PASSWORD}"
    VNC_GEOMETRY="${VNC_GEOMETRY:-$DEFAULT_VNC_GEOMETRY}"
    VNC_DEPTH="${VNC_DEPTH:-$DEFAULT_VNC_DEPTH}"
    VNC_PORT="${VNC_PORT:-$DEFAULT_VNC_PORT}"
    NOVNC_PORT="${NOVNC_PORT:-$DEFAULT_NOVNC_PORT}"
    THEME="${THEME:-$DEFAULT_THEME}"
    PERFORMANCE_MODE="${PERFORMANCE_MODE:-$DEFAULT_PERFORMANCE_MODE}"
}

create_default_config() {
    cat > "$CONFIG_FILE" << EOF
# KDE VNC Installation Configuration
# Customize these values before running the installer

# VNC User Configuration
VNC_USER="$DEFAULT_VNC_USER"
VNC_PASSWORD="$DEFAULT_VNC_PASSWORD"

# Display Configuration
VNC_GEOMETRY="$DEFAULT_VNC_GEOMETRY"
VNC_DEPTH="$DEFAULT_VNC_DEPTH"

# Port Configuration
VNC_PORT="$DEFAULT_VNC_PORT"
NOVNC_PORT="$DEFAULT_NOVNC_PORT"

# Desktop Configuration
THEME="$DEFAULT_THEME"
PERFORMANCE_MODE="$DEFAULT_PERFORMANCE_MODE"

# Advanced Options
INSTALL_EXTRA_APPS="true"
ENABLE_AUTOSTART="true"
OPTIMIZE_SYSTEM="true"
EOF
    print_success "Created default configuration file: $CONFIG_FILE"
}

show_config() {
    print_header "Current Configuration"
    echo "VNC User: $VNC_USER"
    echo "VNC Password: $VNC_PASSWORD"
    echo "Display: ${VNC_GEOMETRY}x${VNC_DEPTH}"
    echo "VNC Port: $VNC_PORT"
    echo "noVNC Port: $NOVNC_PORT"
    echo "Theme: $THEME"
    echo "Performance Mode: $PERFORMANCE_MODE"
    echo ""
}

#==============================================================================
# Installation Modules
#==============================================================================

install_kde_desktop() {
    print_header "Installing KDE Desktop Environment"
    ./modules/install-kde.sh "$THEME" "$PERFORMANCE_MODE"
}

setup_vnc_user() {
    print_header "Setting up VNC User: $VNC_USER"
    ./modules/setup-user.sh "$VNC_USER" "$VNC_PASSWORD"
}

install_vnc_server() {
    print_header "Installing VNC Server"
    ./modules/install-vnc.sh "$VNC_USER" "$VNC_PASSWORD" "$VNC_GEOMETRY" "$VNC_DEPTH" "$VNC_PORT"
}

install_novnc() {
    print_header "Installing noVNC Web Interface"
    ./modules/install-novnc.sh "$VNC_PORT" "$NOVNC_PORT"
}

optimize_performance() {
    if [[ "$PERFORMANCE_MODE" == "true" ]]; then
        print_header "Applying Performance Optimizations"
        ./modules/optimize-performance.sh "$VNC_USER"
    fi
}

setup_services() {
    print_header "Setting up System Services"
    ./modules/setup-services.sh "$VNC_USER" "$VNC_PORT" "$NOVNC_PORT"
}

setup_user_services() {
    print_header "Setting up User-Specific Services"
    ./modules/setup-user-services.sh "$VNC_USER" "$VNC_PORT" "$NOVNC_PORT"
}

install_extra_apps() {
    if [[ "$INSTALL_EXTRA_APPS" == "true" ]]; then
        print_header "Installing Additional Applications"
        ./modules/install-apps.sh
    fi
}

#==============================================================================
# Main Installation Process
#==============================================================================

check_requirements() {
    print_header "Checking System Requirements"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
    
    # Check if sudo is available
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is required but not installed"
        exit 1
    fi
    
    # Check Ubuntu version
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ "$ID" != "ubuntu" ]]; then
            print_warning "This script is designed for Ubuntu. Other distributions may not work correctly."
        fi
    fi
    
    # Check available disk space (minimum 5GB)
    available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 5242880 ]]; then
        print_error "Insufficient disk space. At least 5GB required."
        exit 1
    fi
    
    print_success "System requirements check passed"
}

create_modules_directory() {
    if [[ ! -d "modules" ]]; then
        mkdir -p modules
        print_info "Created modules directory"
    fi
}

select_installation_mode() {
    print_header "Installation Mode Selection"
    echo -e "${YELLOW}Select installation mode:${NC}"
    echo "1) 🖥️  First-time server setup (Install KDE + noVNC + User)"
    echo "2) 👤 Add new VNC user (User + VNC only, requires existing KDE)"
    echo "3) ❌ Exit"
    echo
    
    read -p "Enter your choice (1-3): " mode_choice
    
    case $mode_choice in
        1)
            INSTALLATION_MODE="server"
            print_info "Selected: First-time server setup"
            ;;
        2)
            INSTALLATION_MODE="user"
            print_info "Selected: Add new VNC user"
            check_kde_installed
            ;;
        3)
            print_info "Installation cancelled"
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please try again."
            select_installation_mode
            ;;
    esac
}

check_kde_installed() {
    if ! command -v plasmashell &> /dev/null && ! command -v kwin_x11 &> /dev/null; then
        print_error "KDE is not installed on this system!"
        print_info "Please run first-time server setup (option 1) first."
        exit 1
    fi
    print_success "KDE installation detected"
}

main() {
    print_header "KDE Desktop + noVNC Installer"
    
    # Load configuration
    load_config
    
    # Select installation mode
    select_installation_mode
    
    show_config
    
    # Ask for confirmation
    if [[ "$INSTALLATION_MODE" == "server" ]]; then
        echo -e "${YELLOW}This will install KDE desktop, noVNC, and create user '$VNC_USER'. Continue? (y/N)${NC}"
    else
        echo -e "${YELLOW}This will create VNC user '$VNC_USER' and configure remote access. Continue? (y/N)${NC}"
    fi
    
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled by user"
        exit 0
    fi
    
    # Check system requirements
    check_requirements
    
    # Create modules directory
    create_modules_directory
    
    # Run installation steps based on mode
    if [[ "$INSTALLATION_MODE" == "server" ]]; then
        run_server_installation
    else
        run_user_installation
    fi
    
    # Generate connection info
    ./modules/generate-info.sh "$VNC_USER" "$VNC_PASSWORD" "$NOVNC_PORT" "$VNC_PORT" "$INSTALLATION_MODE"
    
    print_header "Installation Complete!"
    if [[ "$INSTALLATION_MODE" == "server" ]]; then
        print_success "KDE Desktop with noVNC has been successfully installed"
    else
        print_success "New VNC user '$VNC_USER' has been successfully added"
    fi
    print_info "Connection details saved to /home/$VNC_USER/connection_info.txt"
    print_info "Web Access: http://localhost:$NOVNC_PORT/vnc.html"
    print_info "VNC Access: localhost:$VNC_PORT (password: $VNC_PASSWORD)"
}

run_server_installation() {
    print_header "Running First-Time Server Installation"
    install_kde_desktop
    setup_vnc_user
    install_vnc_server
    install_novnc
    optimize_performance
    setup_services
    install_extra_apps
}

run_user_installation() {
    print_header "Adding New VNC User"
    setup_vnc_user
    install_vnc_server
    optimize_performance
    setup_user_services
}

# Handle command line arguments
case "${1:-}" in
    --config)
        create_default_config
        print_info "Edit $CONFIG_FILE and run the installer again"
        exit 0
        ;;
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo "Options:"
        echo "  --config    Create default configuration file"
        echo "  --help      Show this help message"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
