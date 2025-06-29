# 🚀 Quick Start Guide

## Installation Modes

### 🖥️ First-Time Server Setup
For new servers without KDE installed:

```bash
./deploy.sh
# Choose option 1: First-time server setup
```

### 👤 Add New VNC User
For existing servers with KDE already installed:

```bash
./deploy.sh
# Choose option 2: Add new VNC user
```

## What You Get

### First-Time Server Setup
✅ **Complete KDE Desktop** - Full desktop environment  
✅ **TigerVNC Server** - Remote access capability  
✅ **noVNC Web Interface** - Browser-based access  
✅ **Default User** - x2 (password: password123)  
✅ **All Applications** - File manager, text editor, browser, office suite  
✅ **Performance Optimizations** - Tuned for remote access  

### Add New VNC User
✅ **New User Account** - Dedicated VNC user  
✅ **Personal VNC Server** - Isolated on unique port  
✅ **Personal noVNC Access** - Dedicated web interface  
✅ **Optimized KDE Config** - Performance tuned  
✅ **Auto Port Assignment** - No conflicts with existing users  

## Access Your Desktop

### First User (Server Setup)
- **Web Browser**: http://localhost:6080/vnc.html
- **VNC Client**: localhost:5901
- **Password**: password123

### Additional Users
- **Web Browser**: http://localhost:[assigned-port]/vnc.html
- **VNC Client**: localhost:[assigned-port]
- **Password**: [configured password]

## Multi-User Management

### List All Users
```bash
./manage-users.sh --list
```

### Check Services
```bash
./manage-users.sh --services
```

### Interactive Management
```bash
./manage-users.sh
```

## Port Allocation

| User | VNC Port | noVNC Port | Web Access |
|------|----------|------------|-------------|
| x2 (first) | 5901 | 6080 | http://localhost:6080/vnc.html |
| x3 | 5902 | 6081 | http://localhost:6081/vnc.html |
| x4 | 5903 | 6082 | http://localhost:6082/vnc.html |
| x5 | 5904 | 6083 | http://localhost:6083/vnc.html |

## Customization

### Server Setup
```bash
./kde-vnc-installer.sh --config
nano kde-vnc-config.conf
./deploy.sh
```

### User Addition
The installer automatically:
- Finds available ports
- Creates isolated user environment
- Sets up dedicated services
- Generates connection info

## Troubleshooting

### Black Screen
- Wait 10-15 seconds for apps to load
- Check logs: `tail /home/[user]/.vnc/*.log`

### Connection Issues
- Check services: `./manage-users.sh --services`
- Restart user VNC: `./manage-users.sh` → option 2

### Port Conflicts
- Use `./manage-users.sh --list` to see port assignments
- Installer automatically finds free ports

## Management Commands

### Server-Wide
```bash
# Check main services
sudo systemctl status novnc.service

# Restart main noVNC
sudo systemctl restart novnc.service
```

### User-Specific
```bash
# Check user service
sudo systemctl status novnc-[username].service

# Restart user VNC
sudo -u [username] vncserver -kill :[display]
sudo -u [username] vncserver :[display]

# View user logs
tail /home/[username]/.vnc/*.log
```

## Security Notes

- Each user has isolated environment
- Dedicated ports prevent conflicts
- Individual password protection
- User privilege separation
- SSH tunneling recommended for remote access

---
**Ready to start?**
- **New server**: Run `./deploy.sh` → option 1
- **Add user**: Run `./deploy.sh` → option 2
- **Manage users**: Run `./manage-users.sh`
