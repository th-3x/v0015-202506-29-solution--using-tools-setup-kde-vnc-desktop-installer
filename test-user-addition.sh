#!/bin/bash

#==============================================================================
# Test Script for User Addition
# This script tests the user addition functionality
#==============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "Testing User Addition Functionality"
echo "=================================="
echo

# Test 1: Check if KDE is installed
print_info "Test 1: Checking KDE installation..."
if command -v plasmashell &> /dev/null || command -v kwin_x11 &> /dev/null; then
    print_success "KDE is installed"
else
    print_error "KDE is not installed - user addition will fail"
    echo "Please run server setup first: ./deploy.sh --server"
    exit 1
fi

# Test 2: Check required commands
print_info "Test 2: Checking required commands..."
missing_commands=()

for cmd in vncserver vncpasswd netstat systemctl useradd; do
    if ! command -v "$cmd" &> /dev/null; then
        missing_commands+=("$cmd")
    fi
done

if [[ ${#missing_commands[@]} -eq 0 ]]; then
    print_success "All required commands available"
else
    print_error "Missing commands: ${missing_commands[*]}"
fi

# Test 3: Check port availability
print_info "Test 3: Checking port availability..."
test_ports=(5902 5903 6081 6082)
available_ports=()

for port in "${test_ports[@]}"; do
    if ! netstat -ln 2>/dev/null | grep -q ":$port " && ! ss -ln 2>/dev/null | grep -q ":$port "; then
        available_ports+=("$port")
    fi
done

if [[ ${#available_ports[@]} -gt 0 ]]; then
    print_success "Available ports: ${available_ports[*]}"
else
    print_warning "No test ports available (this is normal if users exist)"
fi

# Test 4: Check existing VNC users
print_info "Test 4: Checking existing VNC users..."
vnc_users=$(ps aux | grep -E 'Xtigervnc.*:[0-9]+' | grep -v grep | awk '{print $1}' | sort -u)

if [[ -n "$vnc_users" ]]; then
    print_success "Existing VNC users: $(echo $vnc_users | tr '\n' ' ')"
else
    print_warning "No existing VNC users found"
fi

# Test 5: Check noVNC services
print_info "Test 5: Checking noVNC services..."
if systemctl is-active --quiet novnc.service 2>/dev/null; then
    print_success "Main noVNC service is running"
else
    print_warning "Main noVNC service is not running"
fi

user_novnc_services=$(systemctl list-units --type=service 2>/dev/null | grep 'novnc-.*\.service' | wc -l)
if [[ $user_novnc_services -gt 0 ]]; then
    print_success "$user_novnc_services user-specific noVNC services found"
else
    print_info "No user-specific noVNC services found"
fi

echo
echo "Test Summary:"
echo "============="
print_info "System is ready for user addition testing"
print_info "You can now test with: ./deploy.sh --add-user"
print_info "Or use the interactive menu: ./deploy.sh"

echo
echo "Test Users to Try:"
echo "=================="
echo "• try07 (as mentioned in your request)"
echo "• try08 (as mentioned in your request)"
echo "• developer"
echo "• testuser"

echo
echo "Expected Behavior:"
echo "=================="
echo "1. User account creation"
echo "2. VNC password setup"
echo "3. VNC startup script creation"
echo "4. KDE optimizations applied"
echo "5. noVNC service setup"
echo "6. VNC server started"
echo "7. Connection info generated"
