#!/bin/bash

#==============================================================================
# noVNC Installation Module
# Parameters: $1=vnc_port, $2=novnc_port
#==============================================================================

VNC_PORT="$1"
NOVNC_PORT="$2"

print_info() {
    echo -e "\033[0;34mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

print_info "Installing noVNC web interface..."

# Install noVNC and websockify
sudo apt install -y \
    novnc \
    websockify \
    python3-websockify

# Create noVNC systemd service
print_info "Creating noVNC service..."
sudo tee /etc/systemd/system/novnc.service > /dev/null << EOF
[Unit]
Description=noVNC Web Interface
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

# Enable noVNC service
sudo systemctl daemon-reload
sudo systemctl enable novnc.service

print_success "noVNC installation completed"
