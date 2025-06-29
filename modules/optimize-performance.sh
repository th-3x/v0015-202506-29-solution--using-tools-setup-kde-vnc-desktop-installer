#!/bin/bash

#==============================================================================
# Performance Optimization Module
# Parameters: $1=username
#==============================================================================

VNC_USER="$1"

print_info() {
    echo -e "\033[0;34mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

print_info "Applying performance optimizations for $VNC_USER..."

# Create KDE configuration for performance
sudo -u "$VNC_USER" tee "/home/$VNC_USER/.config/kwinrc" > /dev/null << 'EOF'
[Compositing]
AnimationSpeed=0
Backend=OpenGL
Enabled=true
GLCore=false
GLPlatformInterface=glx
GLPreferBufferSwap=a
GLTextureFilter=1
HideCursor=true
OpenGLIsUnsafe=false
UnredirectFullscreen=true
WindowsBlockCompositing=true
XRenderSmoothScale=false

[Plugins]
blurEnabled=false
contrastEnabled=false
desktopchangeosdEnabled=false
highlightwindowEnabled=false
kwin4_effect_fadeEnabled=false
kwin4_effect_translucencyEnabled=false
minimizeanimationEnabled=false
slideEnabled=false
zoomEnabled=false

[Windows]
FocusPolicy=ClickToFocus
GeometryTip=false
Placement=Smart
EOF

# Create KDE globals configuration
sudo -u "$VNC_USER" tee "/home/$VNC_USER/.config/kdeglobals" > /dev/null << 'EOF'
[General]
ColorScheme=BreezeDark
Name=Breeze Dark
widgetStyle=Breeze

[KDE]
AnimationDurationFactor=0
LookAndFeelPackage=org.kde.breezedark.desktop
SingleClick=false

[KFileDialog Settings]
Show Inline Previews=false
Show Preview=false
Show hidden files=false

[PreviewSettings]
MaximumRemoteSize=0
EOF

# Create plasma configuration
sudo -u "$VNC_USER" tee "/home/$VNC_USER/.config/plasmarc" > /dev/null << 'EOF'
[Theme]
name=breeze-dark

[General]
BrowserApplication=firefox.desktop
TerminalApplication=konsole.desktop

[KDE]
LookAndFeelPackage=org.kde.breezedark.desktop
SingleClick=false
EOF

# Create performance optimization script
sudo -u "$VNC_USER" tee "/home/$VNC_USER/.vnc/optimize.sh" > /dev/null << 'EOF'
#!/bin/bash

# Disable unnecessary services for performance
export QT_X11_NO_MITSHM=1
export QT_GRAPHICSSYSTEM=native

# Disable file indexing for better performance
if command -v balooctl6 >/dev/null 2>&1; then
    balooctl6 disable 2>/dev/null || true
fi

echo "Performance optimizations applied"
EOF

sudo chmod +x "/home/$VNC_USER/.vnc/optimize.sh"

# Set proper ownership
sudo chown -R "$VNC_USER:$VNC_USER" "/home/$VNC_USER/.config"

print_success "Performance optimizations applied"
