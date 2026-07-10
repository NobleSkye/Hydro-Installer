#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Hydro-Installer Firewall Management UI                                             #
#                                                                                    #
# Configure and manage firewall rules for Hydrodactyl Panel and Wings                #
#                                                                                    #
# Copyright (C) 2025, Hydrodactyl                                                     #
#                                                                                    #
######################################################################################

# Check if lib is loaded, load if not or fail otherwise.
fn_exists() { declare -F "$1" >/dev/null; }
if ! fn_exists lib_loaded; then
  if [ -f /tmp/lib.sh ]; then
    if ! source /tmp/lib.sh 2>/dev/null; then
      rm -f /tmp/lib.sh
    fi
  fi
  if ! fn_exists lib_loaded; then
    source <(curl -sSL "${GITHUB_BASE_URL}/${GITHUB_SOURCE}/lib/lib.sh")
  fi
  ! fn_exists lib_loaded && echo "* ERROR: Could not load lib script" && exit 1
fi

check_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be executed with root privileges."
    exit 1
  fi
}

check_root

show_firewall_menu() {
  local choice=""

  while true; do
    print_header
    print_flame "Firewall Management"

    echo ""
    output "${COLOR_CYAN}What would you like to do?${COLOR_NC}"
    echo ""
    output "[${COLOR_BLUE}0${COLOR_NC}] Install/Enable Firewall"
    output "[${COLOR_BLUE}1${COLOR_NC}] Configure Panel Ports (80, 443)"
    output "[${COLOR_BLUE}2${COLOR_NC}] Configure Wings Ports (8080, 2022)"
    output "[${COLOR_BLUE}3${COLOR_NC}] Configure Game Server Ports"
    output "[${COLOR_BLUE}4${COLOR_NC}] Configure All Ports (Panel + Wings + Games)"
    echo ""
    output "[${COLOR_BLUE}5${COLOR_NC}] Back to Main Menu"
    echo ""

    echo -n "* Select an option [0-5]: "
    read -r choice

    case "$choice" in
      0)
        install_firewall
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      1)
        install_firewall
        configure_firewall_rules true true false
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      2)
        install_firewall
        configure_firewall_rules false false true
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      3)
        install_firewall
        local game_ports=false
        ask_game_ports game_ports
        if [ "$game_ports" == true ]; then
          configure_firewall_rules false false false
        fi
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      4)
        install_firewall
        configure_firewall_rules true true true
        local game_ports=false
        ask_game_ports game_ports
        if [ "$game_ports" == true ]; then
          firewall_allow_ports "25565:25665 27015:27150 7777:8000 28015:28025 2456:2466 30120:30130"
          success "Game ports configured"
        fi
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      5)
        return 0
        ;;
      *)
        error "Invalid option. Please select 0-5."
        sleep 1
        ;;
    esac
  done
}

main() {
  show_firewall_menu
}

main "$@"
