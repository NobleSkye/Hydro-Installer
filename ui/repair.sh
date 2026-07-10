#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Hydro-Installer Repair Tool UI                                                     #
#                                                                                    #
# Repair and fix common issues with Hydrodactyl Panel and Wings                      #
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

show_repair_menu() {
  local choice=""

  while true; do
    print_header
    print_flame "Repair Tool"

    echo ""
    output "${COLOR_CYAN}What would you like to repair?${COLOR_NC}"
    echo ""
    output "[${COLOR_BLUE}0${COLOR_NC}] Fix Panel Permissions"
    output "[${COLOR_BLUE}1${COLOR_NC}] Fix Wings Permissions"
    output "[${COLOR_BLUE}2${COLOR_NC}] Restart All Services"
    output "[${COLOR_BLUE}3${COLOR_NC}] Setup Swap File"
    output "[${COLOR_BLUE}4${COLOR_NC}] Run All Fixes (Recommended)"
    echo ""
    output "[${COLOR_BLUE}5${COLOR_NC}] Back to Main Menu"
    echo ""

    echo -n "* Select an option [0-5]: "
    read -r choice

    case "$choice" in
      0)
        fix_panel_permissions
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      1)
        fix_wings_permissions
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      2)
        restart_services
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      3)
        setup_swap_menu
        continue
        ;;
      4)
        run_all_fixes
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

setup_swap_menu() {
  print_flame "Setup Swap File"

  local swap_mb=$(free -m 2>/dev/null | awk '/^Swap:/{print $2}' || echo "0")

  if [ "$swap_mb" -gt 0 ]; then
    local swap_human=$(free -h 2>/dev/null | awk '/^Swap:/{print $2}' || echo "0")
    info "Swap is already configured: $swap_human"
    echo ""
    output "Would you like to recreate the swap file? [y/N]: "
    read -r recreate_swap
    recreate_swap=$(echo "$recreate_swap" | tr '[:upper:]' '[:lower:]')
    if [ "$recreate_swap" != "y" ]; then
      output "Press Enter to return to the menu..."
      read -r
      return
    fi
    swapoff /swapfile 2>/dev/null || true
    sed -i '/\/swapfile/d' /etc/fstab
    rm -f /swapfile
  fi

  echo ""
  output "Select swap size:"
  output "[${COLOR_BLUE}1${COLOR_NC}] 1GB"
  output "[${COLOR_BLUE}2${COLOR_NC}] 2GB (recommended)"
  output "[${COLOR_BLUE}3${COLOR_NC}] 4GB"
  output "[${COLOR_BLUE}4${COLOR_NC}] Custom"
  echo ""
  echo -n "* Select an option [1-4]: "
  read -r swap_choice

  local swap_size=""
  case "$swap_choice" in
    1) swap_size="1G" ;;
    2) swap_size="2G" ;;
    3) swap_size="4G" ;;
    4)
      echo -n "* Enter swap size (e.g., 512M, 2G) [2G]: "
      read -r swap_size
      [ -z "$swap_size" ] && swap_size="2G"
      ;;
    *)
      warning "Invalid option. Using 2G."
      swap_size="2G"
      ;;
  esac

  setup_swap "$swap_size"
  echo ""
  output "Press Enter to return to the menu..."
  read -r
}

main() {
  show_repair_menu
}

main "$@"
