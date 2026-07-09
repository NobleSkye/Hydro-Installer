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

execute() {
  echo -e "\n\n* hydro-installer $(date) \n\n" >>$LOG_PATH

  run_ui "$1" |& tee -a $LOG_PATH

  if [[ -n $2 ]]; then
    echo -e -n "* Installation of $1 completed. Do you want to proceed to $2 installation? (y/N): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ [Yy] ]]; then
      execute "$2"
    else
      error "Installation of $2 aborted."
      exit 1
    fi
  fi
}

welcome ""

done=false
while [ "$done" == false ]; do
  options=(
    "Install Docker only (standalone Docker Engine)"
    "Install Hydrodactyl Panel (Docker + Docker Compose + Panel)"
    "Install Wings (Docker + Wings daemon)"
    "Install both Panel and Wings on the same machine"
  )

  actions=(
    "docker"
    "panel"
    "wings"
    "panel;wings"
  )

  output "What would you like to do?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && IFS=";" read -r i1 i2 <<<"${actions[$action]}" && execute "$i1" "$i2"
done
