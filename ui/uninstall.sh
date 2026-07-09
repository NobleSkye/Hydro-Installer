#!/bin/bash

set -e

fn_exists() { declare -F "$1" >/dev/null; }
if ! fn_exists lib_loaded; then
  source /tmp/lib.sh || source <(curl -sSL "$GITHUB_URL/lib/lib.sh")
  ! fn_exists lib_loaded && echo "* ERROR: Could not load lib script" && exit 1
fi

RM_PANEL=false
RM_WINGS=false
RM_DB=false

main() {
  welcome

  output "This will remove Hydrodactyl panel and/or Wings from your system."
  output "Docker will be kept installed, but containers and images will be pruned."
  print_brake 50

  if [ -d /srv/hydrodactyl ]; then
    echo -e -n "* Remove Hydrodactyl panel? (y/N): "
    read -r CONFIRM_PANEL
    [[ "$CONFIRM_PANEL" =~ [Yy] ]] && RM_PANEL=true
  fi

  if [ -f /usr/local/bin/wings ] || [ -d /etc/pterodactyl ]; then
    echo -e -n "* Remove Wings? (y/N): "
    read -r CONFIRM_WINGS
    [[ "$CONFIRM_WINGS" =~ [Yy] ]] && RM_WINGS=true
  fi

  if [ "$RM_PANEL" == false ] && [ "$RM_WINGS" == false ]; then
    error "Nothing selected for removal."
    exit 1
  fi

  if (command -v mariadb &>/dev/null || command -v mysql &>/dev/null); then
    echo -e -n "* Remove panel database and user? (y/N): "
    read -r CONFIRM_DB
    [[ "$CONFIRM_DB" =~ [Yy] ]] && RM_DB=true
  fi

  print_brake 50
  [ "$RM_PANEL" == true ] && output "Panel: will be removed"
  [ "$RM_WINGS" == true ] && output "Wings: will be removed"
  [ "$RM_DB" == true ] && output "Database: will be removed"
  print_brake 50

  echo -e -n "\n* Proceed with uninstallation? (y/N): "
  read -r CONFIRM
  if [[ "$CONFIRM" =~ [Yy] ]]; then
    export RM_PANEL RM_WINGS RM_DB
    run_installer "uninstall"
  else
    error "Uninstallation aborted."
    exit 1
  fi
}

main
