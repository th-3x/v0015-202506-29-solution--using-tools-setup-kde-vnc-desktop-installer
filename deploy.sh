#!/bin/bash

#==============================================================================
# KDE VNC Desktop Installer - Quick Deploy Script
# Version: 1.0
# Description: One-command deployment for KDE desktop with noVNC access
#==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    KDE VNC Desktop Installer v1.0                           ║"
    echo "║                   One-Click Remote Desktop Solution                          ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Main deployment function
main() {
    print_banner
    
    echo -e "${PURPLE}🚀 Welcome to KDE VNC Desktop Installer!${NC}"
    echo
    echo "This tool will install:"
    echo "• KDE Plasma Desktop Environment"
    echo "• TigerVNC Server for remote access"
    echo "• noVNC Web Interface (browser access)"
    echo "• Performance optimizations"
    echo "• Essential applications"
    echo
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "Please do not run this script as root!"
        print_info "Run as regular user with sudo privileges"
        exit 1
    fi
    
    # Check for sudo
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is required but not installed"
        exit 1
    fi
    
    # Show options
    echo -e "${YELLOW}Choose installation type:${NC}"
    echo "1) 🖥️  First-time server setup (Install KDE + noVNC + User)"
    echo "2) 👤 Add new VNC user (User + VNC only)"
    echo "3) 🛠️  Manage existing users"
    echo "4) 📖 View Documentation"
    echo "5) 💡 Show Examples"
    echo "6) ❌ Exit"
    echo
    
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            print_info "Starting first-time server installation..."
            server_install
            ;;
        2)
            print_info "Starting new user addition..."
            user_install
            ;;
        3)
            print_info "Opening user management..."
            if [[ -f "./manage-users.sh" ]]; then
                ./manage-users.sh
            else
                print_error "User management script not found!"
                read -p "Press Enter to continue..."
            fi
            main
            ;;
        4)
            print_info "Opening documentation..."
            less README.md
            main
            ;;
        5)
            print_info "Showing examples..."
            ./examples.sh
            echo
            main
            ;;
        6)
            print_info "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please try again."
            main
            ;;
    esac
}

server_install() {
    print_info "First-time server installation will install:"
    echo "• KDE Plasma Desktop Environment"
    echo "• TigerVNC Server"
    echo "• noVNC Web Interface"
    echo "• VNC User: x2 (default)"
    echo "• Password: password123 (default)"
    echo "• All essential applications"
    echo
    
    read -p "Continue with server setup? (Y/n): " confirm
    if [[ $confirm =~ ^[Nn]$ ]]; then
        main
        return
    fi
    
    print_info "Starting server installation..."
    ./kde-vnc-installer.sh
    show_completion_info "server"
}

user_install() {
    # Check if KDE is already installed
    if ! command -v plasmashell &> /dev/null && ! command -v kwin_x11 &> /dev/null; then
        print_error "KDE is not installed on this system!"
        print_info "Please run first-time server setup (option 1) first."
        read -p "Press Enter to return to main menu..."
        main
        return
    fi
    
    print_success "KDE installation detected"
    print_info "Adding new VNC user will:"
    echo "• Create new system user account"
    echo "• Set up dedicated VNC server"
    echo "• Configure personal noVNC access"
    echo "• Optimize KDE for the user"
    echo "• Use separate ports for isolation"
    echo
    
    # Get user details
    read -p "Enter username for new VNC user: " new_user
    if [[ -z "$new_user" ]]; then
        print_error "Username cannot be empty!"
        read -p "Press Enter to try again..."
        user_install
        return
    fi
    
    # Check if user already exists
    if id "$new_user" &>/dev/null; then
        print_error "User '$new_user' already exists!"
        read -p "Press Enter to try again..."
        user_install
        return
    fi
    
    read -s -p "Enter password for $new_user: " new_password
    echo
    if [[ -z "$new_password" ]]; then
        print_error "Password cannot be empty!"
        read -p "Press Enter to try again..."
        user_install
        return
    fi
    
    # Find available ports
    vnc_port=$(find_available_port 5902)
    novnc_port=$(find_available_port 6081)
    
    print_info "Configuration:"
    echo "• Username: $new_user"
    echo "• Password: [hidden]"
    echo "• VNC Port: $vnc_port"
    echo "• noVNC Port: $novnc_port"
    echo "• Web Access: http://localhost:$novnc_port/vnc.html"
    echo
    
    read -p "Continue with user addition? (Y/n): " confirm
    if [[ $confirm =~ ^[Nn]$ ]]; then
        main
        return
    fi
    
    print_info "Creating user account and VNC setup..."
    
    # Create the user account first
    print_info "Step 1: Creating system user '$new_user'..."
    if sudo useradd -m -s /bin/bash "$new_user"; then
        print_success "User account created"
    else
        print_error "Failed to create user account"
        return
    fi
    
    # Set password
    print_info "Step 2: Setting user password..."
    if echo "$new_user:$new_password" | sudo chpasswd; then
        print_success "Password set"
    else
        print_error "Failed to set password"
        return
    fi
    
    # Add to groups
    print_info "Step 3: Adding user to groups..."
    if sudo usermod -aG sudo,audio,video,plugdev,netdev "$new_user"; then
        print_success "User added to groups"
    else
        print_warning "Some groups may not have been added"
    fi
    
    # Create user directories
    print_info "Step 4: Creating user directories..."
    sudo -u "$new_user" mkdir -p "/home/$new_user/.config"
    sudo -u "$new_user" mkdir -p "/home/$new_user/.vnc"
    sudo -u "$new_user" mkdir -p "/home/$new_user/Desktop"
    sudo chown -R "$new_user:$new_user" "/home/$new_user"
    print_success "User directories created"
    
    # Set up VNC password
    print_info "Step 5: Setting up VNC password..."
    sudo -u "$new_user" bash -c "echo '$new_password' | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd"
    print_success "VNC password configured"
    
    # Create VNC startup script
    print_info "Step 6: Creating VNC startup script..."
    sudo tee "/home/$new_user/.vnc/xstartup" > /dev/null << EOF
#!/bin/bash

# Clean environment
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Set display
export DISPLAY=:$(($vnc_port - 5900))

# Basic X11 setup
xrdb \$HOME/.Xresources 2>/dev/null || true
xsetroot -solid darkblue

# Start D-Bus if available
if command -v dbus-launch >/dev/null 2>&1; then
    eval \$(dbus-launch --sh-syntax)
    export DBUS_SESSION_BUS_ADDRESS
fi

# Performance settings
export QT_X11_NO_MITSHM=1

# Start applications
xterm -geometry 80x24+10+10 -ls -title "Terminal - $new_user" &
dolphin &
kate &
kcalc &

# Start window manager and keep session alive
exec openbox
EOF
    
    sudo chmod +x "/home/$new_user/.vnc/xstartup"
    sudo chown "$new_user:$new_user" "/home/$new_user/.vnc/xstartup"
    print_success "VNC startup script created"
    
    # Apply KDE optimizations
    print_info "Step 7: Applying KDE optimizations..."
    apply_user_optimizations "$new_user"
    
    # Set up user-specific noVNC service
    print_info "Step 8: Setting up noVNC service..."
    setup_user_novnc_service "$new_user" "$vnc_port" "$novnc_port"
    
    # Start VNC server
    print_info "Step 9: Starting VNC server..."
    display_num=$(($vnc_port - 5900))
    if sudo -u "$new_user" vncserver ":$display_num" -geometry 1920x1080 -depth 24 -localhost no; then
        print_success "VNC server started on display :$display_num"
    else
        print_error "Failed to start VNC server"
    fi
    
    # Generate connection info
    print_info "Step 10: Generating connection information..."
    generate_user_connection_info "$new_user" "$new_password" "$vnc_port" "$novnc_port"
    
    show_completion_info "user" "$new_user" "$novnc_port" "$vnc_port"
}

find_available_port() {
    local start_port=$1
    local port=$start_port
    
    while netstat -ln 2>/dev/null | grep -q ":$port " || ss -ln 2>/dev/null | grep -q ":$port "; do
        ((port++))
    done
    
    echo $port
}

apply_user_optimizations() {
    local username="$1"
    
    # Create KDE configuration for performance
    sudo -u "$username" tee "/home/$username/.config/kwinrc" > /dev/null << 'EOF'
[Compositing]
AnimationSpeed=0
Backend=OpenGL
Enabled=true
GLCore=false
GLPlatformInterface=glx
GLPreferBufferSwap=a
GLTextureFilter=1
HideCursor=true
OpenGLIsUnsafe=false
UnredirectFullscreen=true
WindowsBlockCompositing=true
XRenderSmoothScale=false

[Plugins]
blurEnabled=false
contrastEnabled=false
desktopchangeosdEnabled=false
highlightwindowEnabled=false
kwin4_effect_fadeEnabled=false
kwin4_effect_translucencyEnabled=false
minimizeanimationEnabled=false
slideEnabled=false
zoomEnabled=false
EOF

    # Create KDE globals configuration
    sudo -u "$username" tee "/home/$username/.config/kdeglobals" > /dev/null << 'EOF'
[General]
ColorScheme=BreezeDark
Name=Breeze Dark
widgetStyle=Breeze

[KDE]
AnimationDurationFactor=0
LookAndFeelPackage=org.kde.breezedark.desktop
SingleClick=false
EOF

    # Create optimization script
    sudo -u "$username" tee "/home/$username/.vnc/optimize.sh" > /dev/null << 'EOF'
#!/bin/bash
export QT_X11_NO_MITSHM=1
export QT_GRAPHICSSYSTEM=native
if command -v balooctl6 >/dev/null 2>&1; then
    balooctl6 disable 2>/dev/null || true
fi
echo "Performance optimizations applied"
EOF
    
    sudo chmod +x "/home/$username/.vnc/optimize.sh"
    sudo chown -R "$username:$username" "/home/$username/.config"
}

setup_user_novnc_service() {
    local username="$1"
    local vnc_port="$2"
    local novnc_port="$3"
    
    # Create user-specific noVNC service
    sudo tee "/etc/systemd/system/novnc-$username.service" > /dev/null << EOF
[Unit]
Description=noVNC Web Interface for $username
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/share/novnc/utils/novnc_proxy --vnc localhost:$vnc_port --listen $novnc_port
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start the service
    sudo systemctl daemon-reload
    sudo systemctl enable "novnc-$username.service"
    sudo systemctl start "novnc-$username.service"
    
    # Wait a moment and check status
    sleep 2
    if sudo systemctl is-active --quiet "novnc-$username.service"; then
        print_success "noVNC service started for $username on port $novnc_port"
    else
        print_warning "noVNC service may need manual start"
    fi
}

generate_user_connection_info() {
    local username="$1"
    local password="$2"
    local vnc_port="$3"
    local novnc_port="$4"
    
    # Get server IP
    local server_ip=$(hostname -I | awk '{print $1}')
    
    sudo -u "$username" tee "/home/$username/connection_info.txt" > /dev/null << EOF
👤 VNC User Added - $username
=============================

✅ STATUS: USER READY FOR REMOTE ACCESS!

🔐 LOGIN CREDENTIALS:
User: $username
Password: $password
VNC Password: $password

🌐 WEB ACCESS (Recommended):
Local: http://localhost:$novnc_port/vnc.html
Remote: http://$server_ip:$novnc_port/vnc.html

📱 VNC CLIENT ACCESS:
Local: localhost:$vnc_port
Remote: $server_ip:$vnc_port
Password: $password

🚀 CONNECTION STEPS:
1. Open web browser
2. Navigate to: http://localhost:$novnc_port/vnc.html
3. Click "Connect"
4. Enter VNC password: $password
5. Access your personal desktop!

🖱️ DESKTOP FEATURES:
- Personal KDE desktop session
- Lightweight Openbox window manager
- KDE applications available
- Performance optimized configuration
- Isolated user environment

🔧 USER SERVICES:
✅ VNC Server: Port $vnc_port (dedicated)
✅ noVNC Web Interface: Port $novnc_port (dedicated)
✅ KDE Configuration: Optimized
✅ Auto-start: Enabled

🛠️ USER MANAGEMENT:
Restart VNC: sudo -u $username vncserver -kill :$(($vnc_port - 5900)) && sudo -u $username vncserver :$(($vnc_port - 5900))
Check Service: sudo systemctl status novnc-$username.service
View Logs: tail /home/$username/.vnc/*.log

Generated on: $(date)
Server IP: $server_ip
Installation Type: Additional user
EOF

    # Create desktop shortcut
    sudo -u "$username" tee "/home/$username/Desktop/Connection_Info.desktop" > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Connection Info - $username
Comment=VNC Connection Information for $username
Exec=kate /home/$username/connection_info.txt
Icon=text-x-generic
Terminal=false
Categories=Utility;
EOF

    sudo chmod +x "/home/$username/Desktop/Connection_Info.desktop"
}

show_completion_info() {
    local mode="${1:-server}"
    local user="${2:-x2}"
    local novnc_port="${3:-6080}"
    local vnc_port="${4:-5901}"
    
    if [[ "$mode" == "server" ]]; then
        print_success "Server installation completed successfully!"
        echo
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗"
        echo "║                     🎉 SERVER INSTALLATION COMPLETE! 🎉                    ║"
        echo "╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    else
        print_success "User addition completed successfully!"
        echo
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗"
        echo "║                        👤 NEW USER ADDED SUCCESSFULLY! 👤                   ║"
        echo "╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    fi
    echo
    
    # Read config to show actual values
    if [[ -f kde-vnc-config.conf ]]; then
        source kde-vnc-config.conf
        user="$VNC_USER"
        novnc_port="$NOVNC_PORT"
        vnc_port="$VNC_PORT"
    fi
    
    echo -e "${GREEN}🌐 ACCESS YOUR DESKTOP:${NC}"
    echo "┌─────────────────────────────────────────────────────────────────────────────┐"
    echo "│ Web Browser (Recommended):                                                  │"
    echo "│   http://localhost:${novnc_port}/vnc.html                                           │"
    echo "│                                                                             │"
    echo "│ VNC Client:                                                                 │"
    echo "│   Server: localhost:${vnc_port}                                                    │"
    echo "│   Password: [configured password]                                           │"
    echo "└─────────────────────────────────────────────────────────────────────────────┘"
    echo
    
    if [[ "$mode" == "server" ]]; then
        echo -e "${BLUE}📋 WHAT'S INSTALLED:${NC}"
        echo "• Complete KDE Desktop Environment"
        echo "• TigerVNC Server with Openbox window manager"
        echo "• noVNC Web Interface for browser access"
        echo "• File Manager, Text Editor, Terminal, Calculator"
        echo "• Firefox, LibreOffice, VLC, GIMP"
        echo "• Performance optimizations for remote access"
    else
        echo -e "${BLUE}📋 USER ADDED:${NC}"
        echo "• New VNC user: $user"
        echo "• Dedicated VNC server on port $vnc_port"
        echo "• Personal noVNC web interface on port $novnc_port"
        echo "• Optimized KDE configuration"
        echo "• Isolated user environment"
    fi
    echo
    
    echo -e "${YELLOW}🔧 MANAGEMENT COMMANDS:${NC}"
    if [[ "$mode" == "server" ]]; then
        echo "• Check Status: sudo systemctl status novnc.service"
        echo "• Restart VNC: sudo -u $user vncserver -kill :1 && sudo -u $user vncserver :1"
    else
        echo "• Check Status: sudo systemctl status novnc-$user.service"
        echo "• Restart VNC: sudo -u $user vncserver -kill :$(($vnc_port - 5900)) && sudo -u $user vncserver :$(($vnc_port - 5900))"
    fi
    echo "• View Logs: tail /home/$user/.vnc/*.log"
    echo "• Connection Info: cat /home/$user/connection_info.txt"
    echo
    
    if [[ "$mode" == "server" ]]; then
        echo -e "${PURPLE}➕ ADD MORE USERS:${NC}"
        echo "• Run this installer again and select 'Add new VNC user'"
        echo "• Each user gets dedicated ports and isolated environment"
        echo
    fi
    
    echo -e "${PURPLE}📚 DOCUMENTATION:${NC}"
    echo "• Full Guide: cat README.md"
    echo "• Quick Help: cat INSTALL.md"
    echo "• Examples: ./examples.sh"
    echo
    
    if [[ "$mode" == "server" ]]; then
        print_success "Your KDE server is ready! Open your browser and enjoy!"
    else
        print_success "User $user is ready for remote access!"
    fi
}

# Handle command line arguments
case "${1:-}" in
    --server)
        print_banner
        server_install
        ;;
    --add-user|--user)
        print_banner
        user_install
        ;;
    --help|-h)
        print_banner
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --server     First-time server setup (KDE + noVNC + User)"
        echo "  --add-user   Add new VNC user (User + VNC only)"
        echo "  --user       Alias for --add-user"
        echo "  --help       Show this help message"
        echo
        echo "Interactive mode (default): $0"
        echo
        echo "Examples:"
        echo "  $0                    # Interactive menu"
        echo "  $0 --server          # Direct server installation"
        echo "  $0 --add-user        # Direct user addition"
        ;;
    *)
        main
        ;;
esac
