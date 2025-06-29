#!/bin/bash

#==============================================================================
# User-Specific Services Setup Module
# Parameters: $1=username, $2=vnc_port, $3=novnc_port
# Description: Sets up services for additional VNC users (not first-time setup)
#==============================================================================

VNC_USER="$1"
VNC_PORT="$2"
NOVNC_PORT="$3"

print_info() {
    echo -e "\033[0;34mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

print_warning() {
    echo -e "\033[1;33m⚠️  $1\033[0m"
}

print_info "Setting up services for user: $VNC_USER"

# Check if this is the first user (default ports)
if [[ "$VNC_PORT" == "5901" && "$NOVNC_PORT" == "6080" ]]; then
    print_info "Setting up primary user services..."
    
    # Enable the main VNC service
    sudo systemctl enable "vncserver@$VNC_USER.service"
    
    # Start main noVNC service if not running
    if ! sudo systemctl is-active --quiet novnc.service; then
        sudo systemctl start novnc.service
    fi
    
else
    print_info "Setting up additional user services for ports VNC:$VNC_PORT, noVNC:$NOVNC_PORT..."
    
    # Create user-specific noVNC service
    sudo tee "/etc/systemd/system/novnc-$VNC_USER.service" > /dev/null << EOF
[Unit]
Description=noVNC Web Interface for $VNC_USER
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

    # Enable and start user-specific services
    sudo systemctl daemon-reload
    sudo systemctl enable "novnc-$VNC_USER.service"
    sudo systemctl enable "vncserver@$VNC_USER.service"
    sudo systemctl start "novnc-$VNC_USER.service"
fi

# Start VNC server for the user
print_info "Starting VNC server for $VNC_USER..."
sudo -u "$VNC_USER" vncserver ":$(($VNC_PORT - 5900))" -geometry 1920x1080 -depth 24 -localhost no

# Verify services
print_info "Verifying services..."
sleep 2

if sudo systemctl is-active --quiet "vncserver@$VNC_USER.service" 2>/dev/null || pgrep -f "Xtigervnc.*:$(($VNC_PORT - 5900))" >/dev/null; then
    print_success "VNC server is running for $VNC_USER"
else
    print_warning "VNC server may need manual start"
fi

if [[ "$VNC_PORT" != "5901" ]] && sudo systemctl is-active --quiet "novnc-$VNC_USER.service"; then
    print_success "noVNC service is running for $VNC_USER on port $NOVNC_PORT"
elif [[ "$VNC_PORT" == "5901" ]] && sudo systemctl is-active --quiet novnc.service; then
    print_success "Main noVNC service is running on port $NOVNC_PORT"
else
    print_warning "noVNC service may need manual start"
fi

print_success "User services setup completed for $VNC_USER"

# Show service status
print_info "Service status summary:"
echo "VNC Port: $VNC_PORT"
echo "noVNC Port: $NOVNC_PORT"
echo "Web Access: http://localhost:$NOVNC_PORT/vnc.html"
