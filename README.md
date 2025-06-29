# KDE Desktop + noVNC One-Click Installer

A comprehensive, modular installation system for setting up an optimized KDE desktop environment with noVNC web-based remote access.

## 🚀 Quick Start

```bash
# Download and run the installer
git clone <repository-url>
cd kde-vnc-installer
./kde-vnc-installer.sh
```

## 📋 Features

- ✅ **One-Click Installation**: Automated setup of complete KDE desktop environment
- ✅ **Web-Based Access**: noVNC interface accessible via web browser
- ✅ **Performance Optimized**: Lightweight configuration for remote access
- ✅ **Modular Design**: Customizable components and easy maintenance
- ✅ **User Configurable**: Easy configuration file for customization
- ✅ **Auto-Start Services**: Automatic service startup on boot
- ✅ **Comprehensive Apps**: Includes essential applications and tools

## 🏗️ Architecture

### Main Components

```
kde-vnc-installer/
├── kde-vnc-installer.sh      # Main installation script
├── kde-vnc-config.conf       # Configuration file
├── README.md                 # This documentation
└── modules/                  # Installation modules
    ├── install-kde.sh        # KDE desktop installation
    ├── setup-user.sh         # VNC user setup
    ├── install-vnc.sh        # VNC server installation
    ├── install-novnc.sh      # noVNC web interface
    ├── optimize-performance.sh # Performance optimizations
    ├── setup-services.sh     # System services configuration
    ├── install-apps.sh       # Additional applications
    └── generate-info.sh      # Connection info generation
```

## ⚙️ Configuration

### Default Configuration

The installer uses the following default settings:

| Setting | Default Value | Description |
|---------|---------------|-------------|
| VNC_USER | x2 | Username for VNC access |
| VNC_PASSWORD | password123 | Password for VNC and user login |
| VNC_GEOMETRY | 1920x1080 | Desktop resolution |
| VNC_DEPTH | 24 | Color depth |
| VNC_PORT | 5901 | VNC server port |
| NOVNC_PORT | 6080 | noVNC web interface port |
| THEME | breeze-dark | KDE theme |
| PERFORMANCE_MODE | true | Enable performance optimizations |

### Customization

1. **Generate configuration file:**
   ```bash
   ./kde-vnc-installer.sh --config
   ```

2. **Edit configuration:**
   ```bash
   nano kde-vnc-config.conf
   ```

3. **Run installer with custom config:**
   ```bash
   ./kde-vnc-installer.sh
   ```

## 🔧 Installation Process

### System Requirements

- **OS**: Ubuntu 20.04+ (other Debian-based distributions may work)
- **RAM**: Minimum 2GB, recommended 4GB+
- **Storage**: Minimum 5GB free space
- **Network**: Internet connection for package downloads
- **Privileges**: sudo access required

### Installation Steps

1. **System Check**: Validates requirements and available resources
2. **KDE Installation**: Installs KDE Plasma desktop environment
3. **User Setup**: Creates and configures VNC user account
4. **VNC Server**: Installs and configures TigerVNC server
5. **noVNC Setup**: Installs web-based VNC client
6. **Performance Optimization**: Applies performance tweaks
7. **Service Configuration**: Sets up auto-start services
8. **Additional Apps**: Installs extra applications (optional)
9. **Info Generation**: Creates connection documentation

## 🌐 Access Methods

### Web Browser Access (Recommended)

```
URL: http://localhost:6080/vnc.html
Password: [configured VNC password]
```

### VNC Client Access

```
Server: localhost:5901
Password: [configured VNC password]
```

### SSH Tunnel (for remote access)

```bash
ssh -L 6080:localhost:6080 -L 5901:localhost:5901 user@server-ip
```

## 👥 Multiple Users Setup

### Adding noVNC for Additional Users

If you have multiple VNC users (e.g., x2, x3, x4), you can set up separate noVNC instances for each user:

#### 1. Check Existing VNC Sessions
```bash
# View current VNC processes and ports
ps aux | grep vnc

# Check listening ports
sudo netstat -tlnp | grep -E ':(590[0-9]|608[0-9])'
```

#### 2. Create Separate noVNC Service for Each User
```bash
# Example for user x3 on VNC port 5902, noVNC port 6081
sudo tee /etc/systemd/system/novnc-x3.service > /dev/null << 'EOF'
[Unit]
Description=noVNC Web Interface for x3
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/share/novnc/utils/novnc_proxy --vnc localhost:5902 --listen 6081
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

#### 3. Enable and Start the Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable novnc-x3.service
sudo systemctl start novnc-x3.service
```

#### 4. Verify Service Status
```bash
sudo systemctl status novnc-x3.service
```

### Port Allocation Strategy
| User | VNC Display | VNC Port | noVNC Port | Web Access URL |
|------|-------------|----------|------------|----------------|
| x2   | :1          | 5901     | 6080       | http://localhost:6080/vnc.html |
| x3   | :2          | 5902     | 6081       | http://localhost:6081/vnc.html |
| x4   | :3          | 5903     | 6082       | http://localhost:6082/vnc.html |
| x5   | :4          | 5904     | 6083       | http://localhost:6083/vnc.html |

### Multi-User SSH Tunnel
```bash
# For accessing multiple users remotely
ssh -L 6080:localhost:6080 -L 6081:localhost:6081 -L 6082:localhost:6082 \
    -L 5901:localhost:5901 -L 5902:localhost:5902 -L 5903:localhost:5903 \
    user@server-ip
```

### Managing Multiple noVNC Services
```bash
# Check all noVNC services
sudo systemctl status novnc*.service

# Restart specific user service
sudo systemctl restart novnc-x3.service

# View logs for specific user
journalctl -u novnc-x3.service -f

# Stop/start all noVNC services
sudo systemctl stop novnc*.service
sudo systemctl start novnc*.service
```

## 🖥️ Desktop Environment

### Window Manager
- **Primary**: Openbox (lightweight, stable)
- **Fallback**: KDE Plasma (full desktop experience)

### Included Applications
- **File Manager**: Dolphin
- **Text Editor**: Kate
- **Terminal**: Konsole/xterm
- **Calculator**: KCalc
- **Web Browser**: Firefox
- **Office Suite**: LibreOffice
- **Media Player**: VLC
- **Image Editor**: GIMP

### Performance Optimizations
- Disabled desktop animations and effects
- Reduced compositor overhead
- Disabled file indexing (Baloo)
- Optimized window management
- Fast OpenGL rendering
- Minimal theme configuration

## 🔧 Module Details

### install-kde.sh
Installs KDE Plasma desktop environment and essential applications.

**Parameters:**
- `$1`: Theme name (default: breeze-dark)
- `$2`: Performance mode (default: true)

**Features:**
- Complete KDE desktop installation
- Theme configuration
- Display manager setup

### setup-user.sh
Creates and configures the VNC user account.

**Parameters:**
- `$1`: Username
- `$2`: Password

**Features:**
- User creation with home directory
- Group membership configuration
- Directory structure setup

### install-vnc.sh
Installs and configures TigerVNC server.

**Parameters:**
- `$1`: Username
- `$2`: Password
- `$3`: Geometry (resolution)
- `$4`: Color depth
- `$5`: Port number

**Features:**
- VNC server installation
- Password configuration
- Startup script creation

### install-novnc.sh
Sets up noVNC web interface.

**Parameters:**
- `$1`: VNC port
- `$2`: noVNC port

**Features:**
- noVNC installation
- Websockify configuration
- Service creation

### optimize-performance.sh
Applies performance optimizations for remote desktop use.

**Parameters:**
- `$1`: Username

**Features:**
- KDE configuration optimization
- Desktop effects disabling
- Performance tuning

### setup-services.sh
Configures system services for auto-start.

**Parameters:**
- `$1`: Username
- `$2`: VNC port
- `$3`: noVNC port

**Features:**
- Systemd service creation
- Auto-start configuration
- Service management

### install-apps.sh
Installs additional applications and tools.

**Features:**
- Development tools
- Media applications
- Office software
- System utilities

### generate-info.sh
Creates connection information and documentation.

**Parameters:**
- `$1`: Username
- `$2`: Password
- `$3`: noVNC port
- `$4`: VNC port

**Features:**
- Connection info generation
- Desktop shortcuts
- Troubleshooting guide

### Multi-User Module Usage

For setting up additional users with noVNC:

```bash
# Set up noVNC for additional user
./modules/install-novnc.sh [vnc_port] [novnc_port]

# Then create user-specific service
sudo tee /etc/systemd/system/novnc-[username].service > /dev/null << 'EOF'
[Unit]
Description=noVNC Web Interface for [username]
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/share/novnc/utils/novnc_proxy --vnc localhost:[vnc_port] --listen [novnc_port]
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
sudo systemctl daemon-reload
sudo systemctl enable novnc-[username].service
sudo systemctl start novnc-[username].service
```

## 🛠️ Management Commands

### Service Management
```bash
# Check service status
sudo systemctl status novnc.service
sudo systemctl status vncserver@[username].service

# Restart services
sudo systemctl restart novnc.service
sudo systemctl restart vncserver@[username].service

# View logs
journalctl -u novnc.service
journalctl -u vncserver@[username].service
```

### VNC Server Management
```bash
# Start VNC server manually
sudo -u [username] vncserver :1 -geometry 1920x1080 -depth 24 -localhost no

# Stop VNC server
sudo -u [username] vncserver -kill :1

# List VNC sessions
sudo -u [username] vncserver -list
```

### Performance Optimization
```bash
# Apply optimizations
/home/[username]/.vnc/optimize.sh

# Check VNC logs
tail -f /home/[username]/.vnc/*.log
```

## 🔍 Troubleshooting

### Common Issues

#### Black Screen on Connection
**Symptoms**: VNC connects but shows only black screen
**Solutions**:
1. Wait 10-15 seconds for applications to load
2. Check VNC logs: `tail /home/[username]/.vnc/*.log`
3. Restart VNC server: `sudo -u [username] vncserver -kill :1 && sudo -u [username] vncserver :1`

#### Connection Refused
**Symptoms**: Cannot connect to VNC or noVNC
**Solutions**:
1. Check if services are running: `sudo systemctl status novnc.service`
2. Verify ports are open: `sudo netstat -tlnp | grep -E ':(5901|6080)'`
3. Check firewall settings: `sudo ufw status`

#### Performance Issues
**Symptoms**: Slow or laggy desktop
**Solutions**:
1. Run performance optimization: `/home/[username]/.vnc/optimize.sh`
2. Reduce resolution: Edit VNC geometry in config
3. Disable unnecessary applications

#### Service Won't Start
**Symptoms**: Services fail to start automatically
**Solutions**:
1. Check service status: `sudo systemctl status [service-name]`
2. View service logs: `journalctl -u [service-name]`
3. Manually restart: `sudo systemctl restart [service-name]`

### Log Locations
- VNC Server: `/home/[username]/.vnc/*.log`
- noVNC Service: `journalctl -u novnc.service`
- System logs: `/var/log/syslog`

### Port Configuration
Default ports used:
- VNC Server: 5901
- noVNC Web: 6080

To change ports, edit `kde-vnc-config.conf` and reinstall.

## 🔒 Security Considerations

### Network Security
- VNC traffic is not encrypted by default
- Use SSH tunneling for remote access
- Consider VPN for production environments
- Firewall configuration recommended

### User Security
- Change default passwords immediately
- Use strong passwords
- Limit VNC user privileges
- Regular security updates

### Firewall Configuration
```bash
# Allow VNC and noVNC ports locally
sudo ufw allow from 127.0.0.1 to any port 5901
sudo ufw allow from 127.0.0.1 to any port 6080

# For remote access (use with caution)
sudo ufw allow 5901
sudo ufw allow 6080
```

## 📝 Customization Examples

### Custom User and Ports
```bash
# Edit kde-vnc-config.conf
VNC_USER="myuser"
VNC_PASSWORD="mypassword"
VNC_PORT="5902"
NOVNC_PORT="6081"
```

### Different Resolution
```bash
# Edit kde-vnc-config.conf
VNC_GEOMETRY="1366x768"
VNC_DEPTH="16"
```

### Minimal Installation
```bash
# Edit kde-vnc-config.conf
INSTALL_EXTRA_APPS="false"
PERFORMANCE_MODE="true"
```

## 🤝 Contributing

### Adding New Modules
1. Create new script in `modules/` directory
2. Follow naming convention: `action-component.sh`
3. Include parameter documentation
4. Add error handling and logging
5. Update main installer script

### Module Template
```bash
#!/bin/bash
#==============================================================================
# Module Name
# Parameters: $1=param1, $2=param2
#==============================================================================

PARAM1="$1"
PARAM2="$2"

print_info() {
    echo -e "\033[0;34mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

print_info "Starting module..."

# Module logic here

print_success "Module completed"
```

## 📄 License

This project is open source and available under the MIT License.

## 🆘 Support

For issues and questions:
1. Check troubleshooting section
2. Review log files
3. Create GitHub issue with:
   - System information
   - Error messages
   - Configuration used
   - Steps to reproduce

---

**Generated by Amazon Q Assistant**
**Version: 1.0**
**Last Updated: $(date)**
