#!/bin/bash

#==============================================================================
# KDE VNC Installer - Usage Examples
#==============================================================================

echo "KDE VNC Installer - Usage Examples"
echo "=================================="
echo

# Example 1: First-Time Server Setup
echo "Example 1: First-Time Server Setup"
echo "----------------------------------"
echo "./deploy.sh"
echo "→ Choose option 1: First-time server setup"
echo "• Installs complete KDE desktop environment"
echo "• Sets up TigerVNC server and noVNC web interface"
echo "• Creates default user 'x2' with password 'password123'"
echo "• Configures all services and optimizations"
echo "• Access: http://localhost:6080/vnc.html"
echo

# Example 2: Add New VNC User
echo "Example 2: Add New VNC User"
echo "---------------------------"
echo "./deploy.sh"
echo "→ Choose option 2: Add new VNC user"
echo "• Requires existing KDE installation"
echo "• Creates new user with dedicated ports"
echo "• Sets up isolated VNC environment"
echo "• Automatic port assignment (no conflicts)"
echo "• Example: User 'x3' gets ports 5902/6081"
echo

# Example 3: Multiple Users Setup
echo "Example 3: Multiple Users Setup"
echo "-------------------------------"
echo "# First: Install server"
echo "./deploy.sh → option 1 (server setup)"
echo "# Result: x2 user on ports 5901/6080"
echo
echo "# Then: Add users"
echo "./deploy.sh → option 2 (add user 'developer')"
echo "# Result: developer user on ports 5902/6081"
echo
echo "./deploy.sh → option 2 (add user 'admin')"
echo "# Result: admin user on ports 5903/6082"
echo

# Example 4: Custom Server Configuration
echo "Example 4: Custom Server Configuration"
echo "-------------------------------------"
echo "# Generate and edit config"
echo "./kde-vnc-installer.sh --config"
echo "nano kde-vnc-config.conf"
echo
echo "# Example custom config:"
echo "VNC_USER=\"myserver\""
echo "VNC_PASSWORD=\"SecurePass123\""
echo "VNC_GEOMETRY=\"1366x768\""
echo "INSTALL_EXTRA_APPS=\"false\""
echo
echo "# Install with custom config"
echo "./deploy.sh → option 1"
echo

# Example 5: Development Team Setup
echo "Example 5: Development Team Setup"
echo "---------------------------------"
echo "# Server setup for team lead"
echo "./deploy.sh → option 1"
echo "User: teamlead, Ports: 5901/6080"
echo
echo "# Add team members"
echo "./deploy.sh → option 2 → 'developer1'"
echo "User: developer1, Ports: 5902/6081"
echo
echo "./deploy.sh → option 2 → 'developer2'"
echo "User: developer2, Ports: 5903/6082"
echo
echo "./deploy.sh → option 2 → 'tester'"
echo "User: tester, Ports: 5904/6083"
echo

# Example 6: Educational Environment
echo "Example 6: Educational Environment"
echo "----------------------------------"
echo "# Teacher's desktop"
echo "./deploy.sh → option 1"
echo "User: teacher, Access: http://server:6080/vnc.html"
echo
echo "# Student accounts"
echo "./deploy.sh → option 2 → 'student1'"
echo "./deploy.sh → option 2 → 'student2'"
echo "./deploy.sh → option 2 → 'student3'"
echo "# Each student gets isolated environment"
echo

echo "Multi-User Management:"
echo "======================"
echo "# List all VNC users"
echo "./manage-users.sh --list"
echo
echo "# Check service status"
echo "./manage-users.sh --services"
echo
echo "# Interactive management"
echo "./manage-users.sh"
echo

echo "Port Allocation Pattern:"
echo "========================"
echo "User 1 (x2):     VNC 5901, noVNC 6080"
echo "User 2 (x3):     VNC 5902, noVNC 6081"
echo "User 3 (x4):     VNC 5903, noVNC 6082"
echo "User 4 (x5):     VNC 5904, noVNC 6083"
echo "..."
echo

echo "Access Methods:"
echo "==============="
echo "# Web Browser (any user)"
echo "http://localhost:[novnc-port]/vnc.html"
echo
echo "# VNC Client (any user)"
echo "localhost:[vnc-port]"
echo
echo "# Remote Access (SSH tunnel)"
echo "ssh -L 6080:localhost:6080 -L 6081:localhost:6081 user@server"
echo "ssh -L 5901:localhost:5901 -L 5902:localhost:5902 user@server"
echo

echo "Management Commands:"
echo "==================="
echo "# Server-wide status"
echo "sudo systemctl status novnc.service"
echo
echo "# User-specific status"
echo "sudo systemctl status novnc-[username].service"
echo
echo "# Restart user VNC"
echo "sudo -u [username] vncserver -kill :[display]"
echo "sudo -u [username] vncserver :[display]"
echo
echo "# View user logs"
echo "tail /home/[username]/.vnc/*.log"
echo
echo "# User connection info"
echo "cat /home/[username]/connection_info.txt"
