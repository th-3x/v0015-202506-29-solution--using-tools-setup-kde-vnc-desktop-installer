#!/bin/bash

#==============================================================================
# Connection Information Generation Module
# Parameters: $1=username, $2=password, $3=novnc_port, $4=vnc_port, $5=mode
#==============================================================================

VNC_USER="$1"
VNC_PASSWORD="$2"
NOVNC_PORT="$3"
VNC_PORT="$4"
INSTALLATION_MODE="${5:-server}"

print_info() {
    echo -e "\033[0;34mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

print_info "Generating connection information for $VNC_USER..."

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Create appropriate connection info based on mode
if [[ "$INSTALLATION_MODE" == "server" ]]; then
    # First-time server setup info
    sudo -u "$VNC_USER" tee "/home/$VNC_USER/connection_info.txt" > /dev/null << EOF
🖥️ KDE Desktop Remote Access - Server Installation Complete
===========================================================

✅ STATUS: READY TO CONNECT!

🔐 LOGIN CREDENTIALS:
User: $VNC_USER
Password: $VNC_PASSWORD
VNC Password: $VNC_PASSWORD

🌐 WEB ACCESS (Recommended):
Local: http://localhost:$NOVNC_PORT/vnc.html
Remote: http://$SERVER_IP:$NOVNC_PORT/vnc.html

📱 VNC CLIENT ACCESS:
Local: localhost:$VNC_PORT
Remote: $SERVER_IP:$VNC_PORT
Password: $VNC_PASSWORD

🚀 CONNECTION STEPS:
1. Open web browser
2. Navigate to: http://localhost:$NOVNC_PORT/vnc.html
3. Click "Connect"
4. Enter VNC password: $VNC_PASSWORD
5. Enjoy your KDE desktop!

🖱️ DESKTOP FEATURES:
- Full KDE Plasma desktop environment
- Lightweight Openbox window manager for performance
- KDE applications (Dolphin, Kate, KCalc, Terminal)
- Right-click for context menu
- Performance optimized for remote access

🔧 SERVICES STATUS:
✅ VNC Server: Port $VNC_PORT
✅ noVNC Web Interface: Port $NOVNC_PORT
✅ KDE Desktop: Fully installed
✅ Auto-start: Enabled

🛠️ MANAGEMENT COMMANDS:
Restart VNC: sudo -u $VNC_USER vncserver -kill :1 && sudo -u $VNC_USER vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
Check Services: sudo systemctl status novnc.service
View Logs: tail /home/$VNC_USER/.vnc/*.log

📋 ADD MORE USERS:
To add additional VNC users, run the installer again and select "Add new VNC user" option.
Each user will get their own VNC and noVNC ports.

Generated on: $(date)
Server IP: $SERVER_IP
Installation Type: First-time server setup
EOF

else
    # Additional user setup info
    sudo -u "$VNC_USER" tee "/home/$VNC_USER/connection_info.txt" > /dev/null << EOF
👤 VNC User Added - $VNC_USER
=============================

✅ STATUS: USER READY FOR REMOTE ACCESS!

🔐 LOGIN CREDENTIALS:
User: $VNC_USER
Password: $VNC_PASSWORD
VNC Password: $VNC_PASSWORD

🌐 WEB ACCESS (Recommended):
Local: http://localhost:$NOVNC_PORT/vnc.html
Remote: http://$SERVER_IP:$NOVNC_PORT/vnc.html

📱 VNC CLIENT ACCESS:
Local: localhost:$VNC_PORT
Remote: $SERVER_IP:$VNC_PORT
Password: $VNC_PASSWORD

🚀 CONNECTION STEPS:
1. Open web browser
2. Navigate to: http://localhost:$NOVNC_PORT/vnc.html
3. Click "Connect"
4. Enter VNC password: $VNC_PASSWORD
5. Access your personal desktop!

🖱️ DESKTOP FEATURES:
- Personal KDE desktop session
- Lightweight Openbox window manager
- KDE applications available
- Performance optimized configuration
- Isolated user environment

🔧 USER SERVICES:
✅ VNC Server: Port $VNC_PORT (dedicated)
✅ noVNC Web Interface: Port $NOVNC_PORT (dedicated)
✅ KDE Configuration: Optimized
✅ Auto-start: Enabled

🛠️ USER MANAGEMENT:
Restart VNC: sudo -u $VNC_USER vncserver -kill :$(($VNC_PORT - 5900)) && sudo -u $VNC_USER vncserver :$(($VNC_PORT - 5900))
Check Service: sudo systemctl status novnc-$VNC_USER.service
View Logs: tail /home/$VNC_USER/.vnc/*.log

📋 MULTI-USER SETUP:
This user has been added to an existing KDE server.
Other users can be added with different port numbers.

Generated on: $(date)
Server IP: $SERVER_IP
Installation Type: Additional user
EOF

fi

# Create desktop shortcut
sudo -u "$VNC_USER" tee "/home/$VNC_USER/Desktop/Connection_Info.desktop" > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Connection Info - $VNC_USER
Comment=VNC Connection Information for $VNC_USER
Exec=kate /home/$VNC_USER/connection_info.txt
Icon=text-x-generic
Terminal=false
Categories=Utility;
EOF

sudo chmod +x "/home/$VNC_USER/Desktop/Connection_Info.desktop"

if [[ "$INSTALLATION_MODE" == "server" ]]; then
    print_success "Server installation info generated at /home/$VNC_USER/connection_info.txt"
else
    print_success "User addition info generated at /home/$VNC_USER/connection_info.txt"
fi
