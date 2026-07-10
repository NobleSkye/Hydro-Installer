#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Project 'hydro-installer'                                                          #
#                                                                                    #
# Hydrodactyl panel & wings installer                                                #
# https://github.com/NobleSkye/Hydro-Installer                                       #
#                                                                                    #
######################################################################################

export GITHUB_SOURCE="master"
export SCRIPT_RELEASE="canary"
export GITHUB_BASE_URL="https://raw.githubusercontent.com/NobleSkye/Hydro-Installer"

LOG_PATH="/var/log/hydro-installer.log"

# Clean up any cached files from previous runs
rm -f /tmp/lib.sh /tmp/hydro-*.sh 2>/dev/null || true

# Error handler
error_handler() {
  local exit_code=$?
  local line_no=$1

  if [ $exit_code -ne 0 ]; then
    echo ""
    echo -e "* ${COLOR_RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "* ${COLOR_RED}INSTALLATION FAILED${COLOR_NC}"
    echo -e "* ${COLOR_RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""
    echo -e "* ${COLOR_YELLOW}Exit code:${COLOR_NC} $exit_code"
    [ -n "$line_no" ] && echo -e "* ${COLOR_YELLOW}Failed at line:${COLOR_NC} $line_no"
    echo ""
    echo -e "* ${COLOR_CYAN}Troubleshooting tips:${COLOR_NC}"
    echo -e "  1. Check the log file: ${COLOR_CYAN}$LOG_PATH${COLOR_NC}"
    echo -e "  2. Ensure you have a stable internet connection"
    echo -e "  3. Check that your OS is supported"
    echo ""
    echo -e "* ${COLOR_RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""
  fi
}

trap 'error_handler $LINENO' ERR

cleanup() {
  rm -f /tmp/lib.sh 2>/dev/null || true
}

trap cleanup EXIT INT TERM

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

# Try local lib.sh first (for local dev), fall back to GitHub (for curl pipe)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
if [ -f "$SCRIPT_DIR/lib/lib.sh" ]; then
  # shellcheck source=lib/lib.sh
  source "$SCRIPT_DIR/lib/lib.sh"
else
  # Always remove lib.sh, before downloading it
  [ -f /tmp/lib.sh ] && rm -rf /tmp/lib.sh
  curl -sSL -o /tmp/lib.sh "$GITHUB_BASE_URL"/master/lib/lib.sh
  # shellcheck source=/tmp/lib.sh
  source /tmp/lib.sh
fi

log_execution() {
  echo -e "\n\n* hydro-installer $(date) \n\n" >> "$LOG_PATH"
}

execute_ui() {
  local script_name="$1"
  local next_script="${2:-}"

  run_ui "$script_name" 2>&1 | tee -a "$LOG_PATH"
  local exit_code=${PIPESTATUS[0]}

  if [ $exit_code -ne 0 ]; then
    exit $exit_code
  fi

  if [[ -z "$next_script" ]]; then
    echo ""
    output "Press Enter to return to the menu..."
    read -r
  fi

  if [[ -n "$next_script" ]]; then
    echo ""
    local CONFIRM=""
    while [[ "$CONFIRM" != "y" && "$CONFIRM" != "n" ]]; do
      echo -n "* Installation of $script_name completed. Do you want to proceed to $next_script installation? [y/N]: "
      read -r CONFIRM
      CONFIRM=$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')
      [ -z "$CONFIRM" ] && CONFIRM="n"
      if [[ "$CONFIRM" != "y" && "$CONFIRM" != "n" ]]; then
        error "Invalid input. Please enter 'y' or 'n'."
      fi
    done
    if [[ "$CONFIRM" == "y" ]]; then
      execute_ui "$next_script"
    else
      warning "Installation of $next_script aborted."
      exit 1
    fi
  fi
}

# Check installations and set state variables
check_installations() {
  PANEL_INSTALLED=false
  WINGS_INSTALLED=false

  if [ -d "/srv/hydrodactyl" ]; then
    PANEL_INSTALLED=true
  fi

  if [ -f "/usr/local/bin/wings" ]; then
    WINGS_INSTALLED=true
  fi
}

show_welcome() {
  welcome

  check_installations

  if [ "$PANEL_INSTALLED" == true ]; then
    echo -e "  ${COLOR_GREEN}✓${COLOR_NC} Panel installed"
  else
    echo -e "  ${COLOR_RED}✗${COLOR_NC} Panel not installed"
  fi

  if [ "$WINGS_INSTALLED" == true ]; then
    echo -e "  ${COLOR_GREEN}✓${COLOR_NC} Wings installed"
  else
    echo -e "  ${COLOR_RED}✗${COLOR_NC} Wings not installed"
  fi

  echo ""
  print_brake 70
  echo ""
}

show_menu() {
  local choice=""

  while true; do
    show_welcome

    echo ""
    output "${COLOR_CYAN}What would you like to do?${COLOR_NC}"
    echo ""
    output "[${COLOR_BLUE}0${COLOR_NC}] Install Docker only"
    output "[${COLOR_BLUE}1${COLOR_NC}] Install Hydrodactyl Panel only"
    output "[${COLOR_BLUE}2${COLOR_NC}] Install Wings only"
    output "[${COLOR_BLUE}3${COLOR_NC}] Install both Panel and Wings"
    echo ""
    output "[${COLOR_BLUE}4${COLOR_NC}] Uninstall"
    echo ""
    output "[${COLOR_BLUE}5${COLOR_NC}] Repair / Fix Common Issues"
    output "[${COLOR_BLUE}6${COLOR_NC}] Health Check"
    output "[${COLOR_BLUE}7${COLOR_NC}] Firewall Management"
    echo ""
    output "[${COLOR_BLUE}8${COLOR_NC}] Exit"
    echo ""

    echo -n "* Select an option [0-8]: "
    read -r choice

    case "$choice" in
      0)
        execute_ui "docker"
        continue
        ;;
      1)
        execute_ui "panel"
        continue
        ;;
      2)
        execute_ui "wings"
        continue
        ;;
      3)
        execute_ui "panel" "wings"
        continue
        ;;
      4)
        execute_ui "uninstall"
        continue
        ;;
      5)
        execute_ui "repair"
        continue
        ;;
      6)
        check_installations
        if [ "$PANEL_INSTALLED" == true ] && [ "$WINGS_INSTALLED" == true ]; then
          check_both_health
        elif [ "$PANEL_INSTALLED" == true ]; then
          check_panel_health
        elif [ "$WINGS_INSTALLED" == true ]; then
          check_wings_health
        else
          check_system_health
        fi
        output "Press Enter to return to the menu..."
        read -r
        continue
        ;;
      7)
        execute_ui "firewall"
        continue
        ;;
      8)
        output "Exiting..."
        exit 0
        ;;
      *)
        error "Invalid option. Please select 0-8."
        sleep 1
        ;;
    esac
  done
}

# Main function
main() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be executed with root privileges."
    exit 1
  fi

  if ! [ -x "$(command -v curl)" ]; then
    error "curl is required in order for this script to work."
    exit 1
  fi

  log_execution
  show_welcome

  # Pre-flight system resource check
  echo ""
  output "${COLOR_CYAN}Running system requirements check...${COLOR_NC}"
  if ! check_system_resources; then
    echo ""
    warning "Your system is below minimum requirements!"
    output "You may experience performance issues or installation failures."
    echo ""
    local continue_anyway=""
    while [[ "$continue_anyway" != "y" && "$continue_anyway" != "n" ]]; do
      echo -n "* Continue anyway? [y/N]: "
      read -r continue_anyway
      continue_anyway=$(echo "$continue_anyway" | tr '[:upper:]' '[:lower:]')
      [ -z "$continue_anyway" ] && continue_anyway="n"
    done
    if [[ "$continue_anyway" == "n" ]]; then
      exit 1
    fi
  fi

  if show_menu; then
    echo ""
    print_flame "Thank you for using Hydro-Installer!"
  fi

  echo ""
  output "Installation log saved to: ${COLOR_CYAN}$LOG_PATH${COLOR_NC}"
  echo ""
}

main "$@"
