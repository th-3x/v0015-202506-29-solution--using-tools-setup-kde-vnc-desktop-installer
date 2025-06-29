# Quick Installation Guide

## 🚀 One-Click Installation

### Step 1: Download
```bash
git clone https://github.com/your-repo/kde-vnc-installer.git
cd kde-vnc-installer
```

### Step 2: Run Installer
```bash
./kde-vnc-installer.sh
```

### Step 3: Access Desktop
Open browser: `http://localhost:6080/vnc.html`
Password: `password123`

## ⚙️ Custom Installation

### Step 1: Generate Config
```bash
./kde-vnc-installer.sh --config
```

### Step 2: Edit Configuration
```bash
nano kde-vnc-config.conf
```

### Step 3: Install with Custom Settings
```bash
./kde-vnc-installer.sh
```

## 🔧 Configuration Options

```bash
# User Settings
VNC_USER="myuser"           # Change VNC username
VNC_PASSWORD="mypass123"    # Change password

# Display Settings
VNC_GEOMETRY="1366x768"     # Change resolution
VNC_DEPTH="24"              # Color depth

# Port Settings
VNC_PORT="5902"             # VNC server port
NOVNC_PORT="6081"           # Web interface port

# Features
INSTALL_EXTRA_APPS="false"  # Skip extra applications
PERFORMANCE_MODE="true"     # Enable optimizations
ENABLE_AUTOSTART="true"     # Auto-start services
```

## 🌐 Access Methods

| Method | URL/Address | Password |
|--------|-------------|----------|
| Web Browser | http://localhost:6080/vnc.html | password123 |
| VNC Client | localhost:5901 | password123 |
| Remote Web | http://your-ip:6080/vnc.html | password123 |
| Remote VNC | your-ip:5901 | password123 |

## 🛠️ Post-Installation

### Check Status
```bash
# Check services
sudo systemctl status novnc.service
ps aux | grep Xtigervnc

# Check ports
sudo netstat -tlnp | grep -E ':(5901|6080)'
```

### Restart Services
```bash
# Restart VNC
sudo -u x2 vncserver -kill :1
sudo -u x2 vncserver :1 -geometry 1920x1080 -depth 24 -localhost no

# Restart noVNC
sudo systemctl restart novnc.service
```

## 🔍 Troubleshooting

### Black Screen
- Wait 10-15 seconds for apps to load
- Check logs: `tail /home/x2/.vnc/*.log`

### Connection Failed
- Check firewall: `sudo ufw status`
- Verify ports: `sudo netstat -tlnp | grep 6080`

### Performance Issues
- Run optimizer: `/home/x2/.vnc/optimize.sh`
- Reduce resolution in config

## 📋 What Gets Installed

### Core Components
- KDE Plasma Desktop
- TigerVNC Server
- noVNC Web Interface
- Openbox Window Manager

### Applications
- Dolphin (File Manager)
- Kate (Text Editor)
- Konsole (Terminal)
- KCalc (Calculator)
- Firefox (Browser)
- LibreOffice (Office Suite)

### Services
- VNC Server (Port 5901)
- noVNC Web Interface (Port 6080)
- Auto-start configuration

## 🔒 Security Notes

- Change default passwords immediately
- Use SSH tunneling for remote access
- Configure firewall appropriately
- Regular system updates recommended

## 📞 Support

Connection info saved to: `/home/x2/connection_info.txt`
Full documentation: `README.md`
Module details: `modules/` directory
