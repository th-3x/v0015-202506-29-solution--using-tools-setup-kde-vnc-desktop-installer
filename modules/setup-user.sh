#!/bin/bash

#==============================================================================
# VNC User Setup Module
# Parameters: $1=username, $2=password
#==============================================================================

VNC_USER="$1"
VNC_PASSWORD="$2"

print_info() {
    echo -e "\033[0;34mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

print_warning() {
    echo -e "\033[1;33m⚠️  $1\033[0m"
}

print_info "Setting up VNC user: $VNC_USER"

# Create user if doesn't exist
if ! id "$VNC_USER" &>/dev/null; then
    print_info "Creating user $VNC_USER..."
    sudo useradd -m -s /bin/bash "$VNC_USER"
    print_success "User $VNC_USER created"
else
    print_warning "User $VNC_USER already exists"
fi

# Set password
print_info "Setting password for user $VNC_USER..."
echo "$VNC_USER:$VNC_PASSWORD" | sudo chpasswd

# Add user to necessary groups
print_info "Adding user to required groups..."
sudo usermod -aG sudo,audio,video,plugdev,netdev "$VNC_USER"

# Create necessary directories
print_info "Creating user directories..."
sudo -u "$VNC_USER" mkdir -p "/home/$VNC_USER/.config"
sudo -u "$VNC_USER" mkdir -p "/home/$VNC_USER/.vnc"
sudo -u "$VNC_USER" mkdir -p "/home/$VNC_USER/Desktop"
sudo -u "$VNC_USER" mkdir -p "/home/$VNC_USER/Documents"
sudo -u "$VNC_USER" mkdir -p "/home/$VNC_USER/Downloads"

# Set proper ownership
sudo chown -R "$VNC_USER:$VNC_USER" "/home/$VNC_USER"

print_success "User setup completed for $VNC_USER"
