#!/bin/bash

set -e

fn_exists() { declare -F "$1" >/dev/null; }
if ! fn_exists lib_loaded; then
  source /tmp/lib.sh || source <(curl -sSL "$GITHUB_URL/lib/lib.sh")
  ! fn_exists lib_loaded && echo "* ERROR: Could not load lib script" && exit 1
fi

# ------------------ Variables ----------------- #

FQDN="${FQDN:-localhost}"

MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
DB_PASSWORD="${DB_PASSWORD:-$(gen_passwd 32)}"

timezone="${timezone:-UTC}"

ASSUME_SSL="${ASSUME_SSL:-false}"
CONFIGURE_LETSENCRYPT="${CONFIGURE_LETSENCRYPT:-false}"
LE_EMAIL="${LE_EMAIL:-}"

email="${email:-}"

INSTALL_DIR="${INSTALL_DIR:-/srv/hydrodactyl}"

# --------- Main installation functions -------- #

install_docker_compose() {
  if command -v docker compose &>/dev/null; then
    output "Docker Compose is already available."
    return 0
  fi
  output "Docker Compose plugin not found, installing..."
  install_packages "docker-compose-plugin"
  success "Docker Compose installed!"
}

download_compose() {
  output "Downloading Hydrodactyl docker-compose file..."

  mkdir -p "$INSTALL_DIR"
  cd "$INSTALL_DIR" || exit

  curl -sSL -o docker-compose.yml "$HYDRO_COMPOSE_URL"

  success "Compose file downloaded to $INSTALL_DIR/docker-compose.yml"
}

configure_compose() {
  output "Configuring docker-compose.yml..."

  APP_URL="http://$FQDN"
  [ "$ASSUME_SSL" == true ] || [ "$CONFIGURE_LETSENCRYPT" == true ] && APP_URL="https://$FQDN"

  if [ -z "$MYSQL_PASSWORD" ]; then
    MYSQL_PASSWORD=$(gen_passwd 32)
  fi

  local mysql_root_password
  mysql_root_password=$(gen_passwd 32)
  DB_PASSWORD="$MYSQL_PASSWORD"

  sed -i "s|CHANGE_ME|$MYSQL_PASSWORD|g" docker-compose.yml
  sed -i "s|CHANGE_ME_TOO|$mysql_root_password|g" docker-compose.yml
  sed -i "s|http://example.com|$APP_URL|g" docker-compose.yml
  sed -i "s|UTC|$timezone|g" docker-compose.yml
  sed -i "s|noreply@example.com|$email|g" docker-compose.yml

  if [ "$CONFIGURE_LETSENCRYPT" == true ] && [ -n "$LE_EMAIL" ]; then
    sed -i "s|# LE_EMAIL: \"\"|LE_EMAIL: \"$LE_EMAIL\"|g" docker-compose.yml
  fi

  success "docker-compose.yml configured!"
}

start_panel_prompt() {
  echo -e -n "* Start the panel now? (y/N): "
  read -r CONFIRM_START
  if [[ ! "$CONFIRM_START" =~ [Yy] ]]; then
    output "Skipping panel start. You can start it later with:"
    output "  cd $INSTALL_DIR && docker compose up -d"
    return 1
  fi
  return 0
}

start_panel() {
  output "Starting Hydrodactyl panel..."

  cd "$INSTALL_DIR" || exit
  docker compose up -d

  success "Hydrodactyl panel started!"
  output "Panel should be accessible at: $APP_URL"
}

# --------------- Main functions --------------- #

perform_install() {
  output "Starting Hydrodactyl panel installation..."

  install_docker
  install_docker_compose
  download_compose
  configure_compose

  if start_panel_prompt; then
    start_panel
  fi

  return 0
}

# ------------------- Install ------------------ #

perform_install
