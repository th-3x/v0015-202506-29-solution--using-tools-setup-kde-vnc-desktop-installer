#!/bin/bash

#==============================================================================
# System Services Setup Module
# Parameters: $1=username, $2=vnc_port, $3=novnc_port
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

print_info "Setting up system services..."

# Create VNC systemd service
print_info "Creating VNC service for $VNC_USER..."
sudo tee /etc/systemd/system/vncserver@.service > /dev/null << EOF
[Unit]
Description=Start TigerVNC server at startup
After=syslog.target network.target

[Service]
Type=simple
User=%i
Group=%i
WorkingDirectory=/home/%i
ExecStartPre=-/usr/bin/vncserver -kill :1
ExecStart=/usr/bin/vncserver -fg :1 -geometry 1920x1080 -depth 24 -localhost no
ExecStop=/usr/bin/vncserver -kill :1
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable services if requested
if [[ "${ENABLE_AUTOSTART:-true}" == "true" ]]; then
    print_info "Enabling auto-start services..."
    sudo systemctl enable "vncserver@$VNC_USER.service"
    sudo systemctl enable novnc.service
fi

# Start services
print_info "Starting services..."
sudo systemctl start novnc.service

# Start VNC server manually (more reliable)
print_info "Starting VNC server for $VNC_USER..."
sudo -u "$VNC_USER" vncserver :1 -geometry 1920x1080 -depth 24 -localhost no

print_success "Services setup completed"
