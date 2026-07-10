#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Hydro-Installer Health Check UI                                                    #
#                                                                                    #
# Health check and diagnostics for Hydrodactyl Panel and Wings                       #
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

detect_panel_location() {
  if [ -d "/srv/hydrodactyl" ] && [ -f "/srv/hydrodactyl/docker-compose.yml" ]; then
    echo "/srv/hydrodactyl"
    return 0
  fi
  return 1
}

detect_wings_binary() {
  if [ -f "/usr/local/bin/wings" ]; then
    echo "/usr/local/bin/wings"
    return 0
  fi
  return 1
}

show_health_menu() {
  local choice=""

  while true; do
    print_header
    print_flame "Health Check & Diagnostics"

    echo ""
    output "${COLOR_CYAN}What would you like to check?${COLOR_NC}"
    echo ""
    output "[${COLOR_BLUE}0${COLOR_NC}] Check Panel Health"
    output "[${COLOR_BLUE}1${COLOR_NC}] Check Wings Health"
    output "[${COLOR_BLUE}2${COLOR_NC}] Check Both"
    output "[${COLOR_BLUE}3${COLOR_NC}] Check System Resources"
    echo ""
    output "[${COLOR_BLUE}4${COLOR_NC}] Back to Main Menu"
    echo ""

    echo -n "* Select an option [0-4]: "
    read -r choice

    case "$choice" in
      0)
        local panel_dir
        panel_dir=$(detect_panel_location) || {
          error "Panel installation not found"
          sleep 2
          continue
        }
        check_panel_health
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      1)
        local wings_binary
        wings_binary=$(detect_wings_binary) || {
          error "Wings installation not found"
          sleep 2
          continue
        }
        check_wings_health
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      2)
        local has_panel=false
        local has_wings=false

        detect_panel_location >/dev/null && has_panel=true
        detect_wings_binary >/dev/null && has_wings=true

        if [ "$has_panel" == false ] && [ "$has_wings" == false ]; then
          error "Neither Panel nor Wings installation found"
          sleep 2
          continue
        fi

        if [ "$has_panel" == true ]; then
          check_panel_health
        fi

        if [ "$has_wings" == true ]; then
          echo ""
          check_wings_health
        fi

        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      3)
        check_system_resources
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      4)
        return 0
        ;;
      *)
        error "Invalid option. Please select 0-4."
        sleep 1
        ;;
    esac
  done
}

main() {
  show_health_menu
}

main "$@"
