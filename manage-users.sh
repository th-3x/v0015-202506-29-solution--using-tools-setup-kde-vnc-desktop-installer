#!/bin/bash

#==============================================================================
# Multi-User VNC Management Script
# Description: Manage multiple VNC users on the system
#==============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                        Multi-User VNC Management                            ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

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

list_vnc_users() {
    print_header
    echo -e "${YELLOW}📋 VNC Users on System:${NC}"
    echo
    
    # Find VNC processes
    vnc_processes=$(ps aux | grep -E 'Xtigervnc.*:[0-9]+' | grep -v grep)
    
    if [[ -z "$vnc_processes" ]]; then
        print_warning "No active VNC sessions found"
        echo
        print_info "To add a VNC user, run: ./deploy.sh --add-user"
        return
    fi
    
    echo "┌─────────────┬──────────┬──────────┬─────────────────────────────────────┐"
    echo "│ User        │ Display  │ VNC Port │ noVNC Port                          │"
    echo "├─────────────┼──────────┼──────────┼─────────────────────────────────────┤"
    
    while IFS= read -r line; do
        user=$(echo "$line" | awk '{print $1}')
        display=$(echo "$line" | grep -o ':[0-9]\+' | head -1)
        vnc_port=$((5900 + ${display:1}))
        
        # Find corresponding noVNC port
        novnc_port=""
        if systemctl is-active --quiet novnc.service 2>/dev/null && [[ "$vnc_port" == "5901" ]]; then
            novnc_port="6080 (main)"
        else
            novnc_service="novnc-$user.service"
            if systemctl is-active --quiet "$novnc_service" 2>/dev/null; then
                novnc_port=$(systemctl show "$novnc_service" -p ExecStart 2>/dev/null | grep -o 'listen [0-9]\+' | awk '{print $2}')
                if [[ -z "$novnc_port" ]]; then
                    novnc_port="Running"
                fi
            else
                novnc_port="Not running"
            fi
        fi
        
        printf "│ %-11s │ %-8s │ %-8s │ %-35s │\n" "$user" "$display" "$vnc_port" "$novnc_port"
    done <<< "$vnc_processes"
    
    echo "└─────────────┴──────────┴──────────┴─────────────────────────────────────┘"
    echo
    
    # Show web access URLs
    echo -e "${GREEN}🌐 Web Access URLs:${NC}"
    while IFS= read -r line; do
        user=$(echo "$line" | awk '{print $1}')
        display=$(echo "$line" | grep -o ':[0-9]\+' | head -1)
        vnc_port=$((5900 + ${display:1}))
        
        if [[ "$vnc_port" == "5901" ]]; then
            echo "• $user: http://localhost:6080/vnc.html"
        else
            novnc_service="novnc-$user.service"
            if systemctl is-active --quiet "$novnc_service" 2>/dev/null; then
                novnc_port=$(systemctl show "$novnc_service" -p ExecStart 2>/dev/null | grep -o 'listen [0-9]\+' | awk '{print $2}')
                if [[ -n "$novnc_port" ]]; then
                    echo "• $user: http://localhost:$novnc_port/vnc.html"
                else
                    echo "• $user: Service running (port unknown)"
                fi
            else
                echo "• $user: noVNC service not running"
            fi
        fi
    done <<< "$vnc_processes"
}

restart_user_vnc() {
    echo -e "${YELLOW}Enter username to restart VNC:${NC}"
    read -p "Username: " username
    
    if ! id "$username" &>/dev/null; then
        print_error "User $username does not exist"
        return
    fi
    
    # Find user's VNC display
    vnc_process=$(ps aux | grep -E "Xtigervnc.*$username" | grep -v grep)
    if [[ -z "$vnc_process" ]]; then
        print_warning "No VNC session found for user $username"
        return
    fi
    
    display=$(echo "$vnc_process" | grep -o ':[0-9]\+' | head -1)
    display_num=${display:1}
    
    print_info "Restarting VNC for user $username (display $display)..."
    
    # Kill existing session
    sudo -u "$username" vncserver -kill "$display" 2>/dev/null || true
    
    # Start new session
    sudo -u "$username" vncserver "$display" -geometry 1920x1080 -depth 24 -localhost no
    
    if [[ $? -eq 0 ]]; then
        print_success "VNC restarted for user $username"
    else
        print_error "Failed to restart VNC for user $username"
    fi
}

check_services() {
    print_header
    echo -e "${YELLOW}🔧 Service Status:${NC}"
    echo
    
    # Check main noVNC service
    echo -e "${BLUE}Main noVNC Service:${NC}"
    if systemctl is-active --quiet novnc.service; then
        print_success "novnc.service is running"
    else
        print_warning "novnc.service is not running"
    fi
    
    # Check user-specific noVNC services
    echo -e "\n${BLUE}User-specific noVNC Services:${NC}"
    user_services=$(systemctl list-units --type=service | grep 'novnc-.*\.service' | awk '{print $1}')
    
    if [[ -z "$user_services" ]]; then
        print_info "No user-specific noVNC services found"
    else
        while IFS= read -r service; do
            if systemctl is-active --quiet "$service"; then
                print_success "$service is running"
            else
                print_warning "$service is not running"
            fi
        done <<< "$user_services"
    fi
    
    # Check VNC server processes
    echo -e "\n${BLUE}VNC Server Processes:${NC}"
    vnc_count=$(ps aux | grep -E 'Xtigervnc.*:[0-9]+' | grep -v grep | wc -l)
    if [[ $vnc_count -gt 0 ]]; then
        print_success "$vnc_count VNC server(s) running"
    else
        print_warning "No VNC servers running"
    fi
}

show_user_info() {
    echo -e "${YELLOW}Enter username to show info:${NC}"
    read -p "Username: " username
    
    if ! id "$username" &>/dev/null; then
        print_error "User $username does not exist"
        return
    fi
    
    if [[ -f "/home/$username/connection_info.txt" ]]; then
        echo -e "\n${GREEN}Connection Info for $username:${NC}"
        echo "════════════════════════════════════════"
        cat "/home/$username/connection_info.txt"
    else
        print_warning "No connection info found for user $username"
    fi
}

main_menu() {
    while true; do
        print_header
        echo -e "${YELLOW}Choose an option:${NC}"
        echo "1) 📋 List all VNC users"
        echo "2) 🔄 Restart user VNC session"
        echo "3) 🔧 Check service status"
        echo "4) ℹ️  Show user connection info"
        echo "5) ➕ Add new VNC user"
        echo "6) ❌ Exit"
        echo
        
        read -p "Enter your choice (1-6): " choice
        
        case $choice in
            1)
                list_vnc_users
                read -p "Press Enter to continue..."
                ;;
            2)
                restart_user_vnc
                read -p "Press Enter to continue..."
                ;;
            3)
                check_services
                read -p "Press Enter to continue..."
                ;;
            4)
                show_user_info
                read -p "Press Enter to continue..."
                ;;
            5)
                print_info "Launching user addition..."
                if [[ -f "./deploy.sh" ]]; then
                    ./deploy.sh --add-user
                else
                    print_error "Deploy script not found!"
                    print_info "Please run from the installer directory"
                fi
                read -p "Press Enter to continue..."
                ;;
            6)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please try again."
                sleep 1
                ;;
        esac
    done
}

# Handle command line arguments
case "${1:-}" in
    --list)
        list_vnc_users
        ;;
    --services)
        check_services
        ;;
    --help|-h)
        print_header
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --list      List all VNC users"
        echo "  --services  Check service status"
        echo "  --help      Show this help message"
        echo
        echo "Interactive mode (default): $0"
        ;;
    *)
        main_menu
        ;;
esac
