#!/bin/bash

#==============================================================================
# Quick Add User Script
# Usage: ./quick-add-user.sh username [password]
#==============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check arguments
if [[ -z "$1" ]]; then
    echo "Usage: $0 username [password]"
    echo "Example: $0 try07"
    echo "Example: $0 try08 mypassword"
    exit 1
fi

USERNAME="$1"
PASSWORD="${2:-password123}"

print_info "Quick adding user: $USERNAME"

# Check if user exists
if id "$USERNAME" &>/dev/null; then
    print_error "User $USERNAME already exists!"
    exit 1
fi

# Check if KDE is installed
if ! command -v plasmashell &> /dev/null && ! command -v kwin_x11 &> /dev/null; then
    print_error "KDE is not installed! Run server setup first."
    exit 1
fi

# Find available ports
find_available_port() {
    local start_port=$1
    local port=$start_port
    
    while netstat -ln 2>/dev/null | grep -q ":$port " || ss -ln 2>/dev/null | grep -q ":$port "; do
        ((port++))
    done
    
    echo $port
}

VNC_PORT=$(find_available_port 5902)
NOVNC_PORT=$(find_available_port 6081)

print_info "Assigned ports: VNC=$VNC_PORT, noVNC=$NOVNC_PORT"

# Create user
print_info "Creating user account..."
if sudo useradd -m -s /bin/bash "$USERNAME"; then
    print_success "User created"
else
    print_error "Failed to create user"
    exit 1
fi

# Set password
print_info "Setting password..."
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# Add to groups
sudo usermod -aG sudo,audio,video,plugdev,netdev "$USERNAME"

# Create directories
sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/.config"
sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/.vnc"
sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/Desktop"

# Set VNC password
print_info "Setting up VNC..."
sudo -u "$USERNAME" bash -c "echo '$PASSWORD' | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd"

# Create VNC startup script
sudo tee "/home/$USERNAME/.vnc/xstartup" > /dev/null << EOF
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export DISPLAY=:$(($VNC_PORT - 5900))
xrdb \$HOME/.Xresources 2>/dev/null || true
xsetroot -solid darkblue
if command -v dbus-launch >/dev/null 2>&1; then
    eval \$(dbus-launch --sh-syntax)
    export DBUS_SESSION_BUS_ADDRESS
fi
export QT_X11_NO_MITSHM=1
xterm -geometry 80x24+10+10 -ls -title "Terminal - $USERNAME" &
dolphin &
kate &
kcalc &
exec openbox
EOF

sudo chmod +x "/home/$USERNAME/.vnc/xstartup"
sudo chown "$USERNAME:$USERNAME" "/home/$USERNAME/.vnc/xstartup"

# Create noVNC service
print_info "Setting up noVNC service..."
sudo tee "/etc/systemd/system/novnc-$USERNAME.service" > /dev/null << EOF
[Unit]
Description=noVNC Web Interface for $USERNAME
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/share/novnc/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NOVNC_PORT
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable "novnc-$USERNAME.service"
sudo systemctl start "novnc-$USERNAME.service"

# Start VNC server
print_info "Starting VNC server..."
DISPLAY_NUM=$(($VNC_PORT - 5900))
sudo -u "$USERNAME" vncserver ":$DISPLAY_NUM" -geometry 1920x1080 -depth 24 -localhost no

# Create connection info
print_info "Creating connection info..."
sudo -u "$USERNAME" tee "/home/$USERNAME/connection_info.txt" > /dev/null << EOF
👤 VNC User: $USERNAME
====================

🌐 Web Access: http://localhost:$NOVNC_PORT/vnc.html
📱 VNC Client: localhost:$VNC_PORT
🔐 Password: $PASSWORD

🛠️ Management:
Restart: sudo -u $USERNAME vncserver -kill :$DISPLAY_NUM && sudo -u $USERNAME vncserver :$DISPLAY_NUM
Service: sudo systemctl status novnc-$USERNAME.service
Logs: tail /home/$USERNAME/.vnc/*.log

Created: $(date)
EOF

sudo chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"

print_success "User $USERNAME added successfully!"
echo
echo "Access Information:"
echo "=================="
echo "Web Browser: http://localhost:$NOVNC_PORT/vnc.html"
echo "VNC Client:  localhost:$VNC_PORT"
echo "Password:    $PASSWORD"
echo
echo "Connection info saved to: /home/$USERNAME/connection_info.txt"
