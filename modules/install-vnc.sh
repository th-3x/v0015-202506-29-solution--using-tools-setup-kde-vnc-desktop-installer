#!/bin/bash

#==============================================================================
# VNC Server Installation Module
# Parameters: $1=user, $2=password, $3=geometry, $4=depth, $5=port
#==============================================================================

VNC_USER="$1"
VNC_PASSWORD="$2"
VNC_GEOMETRY="$3"
VNC_DEPTH="$4"
VNC_PORT="$5"

print_info() {
    echo -e "\033[0;34mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

print_info "Installing VNC Server..."

# Install VNC server and dependencies
sudo apt install -y \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-tools \
    xvfb \
    openbox \
    xterm \
    dbus-x11

# Set up VNC password for user
print_info "Setting up VNC password for $VNC_USER..."
sudo -u "$VNC_USER" bash -c "mkdir -p ~/.vnc && echo '$VNC_PASSWORD' | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd"

# Create VNC startup script
print_info "Creating VNC startup script..."
sudo tee "/home/$VNC_USER/.vnc/xstartup" > /dev/null << EOF
#!/bin/bash

# Clean environment
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Set display
export DISPLAY=:1

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
xterm -geometry 80x24+10+10 -ls -title "Terminal" &
dolphin &
kate &
kcalc &

# Start window manager and keep session alive
exec openbox
EOF

# Make startup script executable
sudo chmod +x "/home/$VNC_USER/.vnc/xstartup"
sudo chown "$VNC_USER:$VNC_USER" "/home/$VNC_USER/.vnc/xstartup"

print_success "VNC Server installation completed"
