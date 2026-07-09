#!/bin/bash

set -e

fn_exists() { declare -F "$1" >/dev/null; }
if ! fn_exists lib_loaded; then
  source /tmp/lib.sh || source <(curl -sSL "$GITHUB_URL/lib/lib.sh")
  ! fn_exists lib_loaded && echo "* ERROR: Could not load lib script" && exit 1
fi

RM_PANEL="${RM_PANEL:-false}"
RM_WINGS="${RM_WINGS:-false}"
RM_DB="${RM_DB:-false}"
INSTALL_DIR="${INSTALL_DIR:-/srv/hydrodactyl}"

rm_panel() {
  output "Removing Hydrodactyl panel..."

  if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR" || exit
    docker compose down -v 2>/dev/null || true
    cd /
    rm -rf "$INSTALL_DIR"
    success "Panel files removed from $INSTALL_DIR"
  else
    warning "Panel directory $INSTALL_DIR not found."
  fi
}

rm_wings() {
  output "Removing Wings..."

  systemctl disable --now wings 2>/dev/null || true
  rm -f /etc/systemd/system/wings.service
  systemctl daemon-reload

  rm -f /usr/local/bin/wings
  rm -rf /etc/pterodactyl
  rm -rf /var/lib/pterodactyl

  success "Wings removed."
}

rm_docker() {
  output "Removing Docker containers and images..."
  docker system prune -a -f 2>/dev/null || true
  success "Docker system pruned."
}

rm_database() {
  if ! command -v mariadb &>/dev/null && ! command -v mysql &>/dev/null; then
    warning "No MariaDB/MySQL client found, skipping database removal."
    return
  fi

  local db_client
  db_client=$(command -v mariadb || command -v mysql)

  output "Removing database..."

  local valid_db
  valid_db=$($db_client -u root -e "SELECT schema_name FROM information_schema.schemata;" 2>/dev/null | grep -v -E -- 'schema_name|information_schema|performance_schema|mysql|sys')
  if [[ -z "$valid_db" ]]; then
    warning "No non-system databases found."
  else
    $db_client -u root -e "DROP DATABASE IF EXISTS panel;" 2>/dev/null || true
    $db_client -u root -e "DROP DATABASE IF EXISTS hydrodactyl;" 2>/dev/null || true
    success "Dropped panel/hydrodactyl database(s)."
  fi

  output "Removing database user..."
  $db_client -u root -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" 2>/dev/null || true
  $db_client -u root -e "DROP USER IF EXISTS 'pterodactyl'@'%';" 2>/dev/null || true
  $db_client -u root -e "DROP USER IF EXISTS 'hydrodactyl'@'127.0.0.1';" 2>/dev/null || true
  $db_client -u root -e "DROP USER IF EXISTS 'hydrodactyl'@'%';" 2>/dev/null || true

  $db_client -u root -e "FLUSH PRIVILEGES;" 2>/dev/null || true
  success "Database user removed."
}

perform_uninstall() {
  [ "$RM_PANEL" == true ] && rm_panel
  [ "$RM_WINGS" == true ] && rm_wings
  [ "$RM_DB" == true ] && rm_database
  [ "$RM_PANEL" == true ] || [ "$RM_WINGS" == true ] && rm_docker
  return 0
}

perform_uninstall
