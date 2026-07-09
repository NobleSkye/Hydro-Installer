#!/bin/bash

set -e

fn_exists() { declare -F "$1" >/dev/null; }
if ! fn_exists lib_loaded; then
  source /tmp/lib.sh || source <(curl -sSL "$GITHUB_URL/lib/lib.sh")
  ! fn_exists lib_loaded && echo "* ERROR: Could not load lib script" && exit 1
fi

# ------------------ Variables ----------------- #

FQDN=""
email=""
timezone="UTC"
LE_EMAIL=""

MYSQL_PASSWORD=""
INSTALL_DIR="/srv/hydrodactyl"
ASSUME_SSL=false
CONFIGURE_LETSENCRYPT=false

# ------------ User input functions ------------ #

ask_letsencrypt() {
  echo -e -n "* Do you want to automatically configure HTTPS using Let's Encrypt? (y/N): "
  read -r CONFIRM_SSL

  if [[ "$CONFIRM_SSL" =~ [Yy] ]]; then
    CONFIGURE_LETSENCRYPT=true
    ASSUME_SSL=false
    echo -n "* Enter email address for Let's Encrypt notifications: "
    read -r LE_EMAIL
  fi
}

check_FQDN_SSL() {
  if [[ $FQDN != 'localhost' ]]; then
    SSL_AVAILABLE=true
  else
    SSL_AVAILABLE=false
    warning "Let's Encrypt requires a valid domain name (not localhost)."
  fi
}

main() {
  welcome

  output "This will install Hydrodactyl Panel using Docker."
  output "You will need a domain name pointing to this server."
  print_brake 50

  while [ -z "$FQDN" ]; do
    echo -n "* Set the FQDN of this panel (panel.example.com): "
    read -r FQDN
    [ -z "$FQDN" ] && error "FQDN cannot be empty"
  done

  check_FQDN_SSL

  echo -n "* Installation directory [$INSTALL_DIR]: "
  read -r dir_input
  [ -n "$dir_input" ] && INSTALL_DIR="$dir_input"

  email_input email "Provide the email address for the panel (e.g. admin@example.com): " "Email cannot be empty or invalid"

  echo -n "* Timezone [UTC]: "
  read -r tz_input
  [ -n "$tz_input" ] && timezone="$tz_input"

  if [ "$SSL_AVAILABLE" == true ]; then
    ask_letsencrypt
    [ "$CONFIGURE_LETSENCRYPT" == false ] && ASSUME_SSL=true
  fi

  print_brake 50
  output "Installation Summary"
  print_brake 50
  output "FQDN: $FQDN"
  output "Install dir: $INSTALL_DIR"
  output "Email: $email"
  output "Timezone: $timezone"
  output "Let's Encrypt: $CONFIGURE_LETSENCRYPT"
  [ "$CONFIGURE_LETSENCRYPT" == true ] && output "LE Email: $LE_EMAIL"
  print_brake 50

  echo -e -n "\n* Proceed with installation? (y/N): "
  read -r CONFIRM
  if [[ "$CONFIRM" =~ [Yy] ]]; then
    export FQDN email timezone MYSQL_PASSWORD \
      ASSUME_SSL CONFIGURE_LETSENCRYPT LE_EMAIL INSTALL_DIR
    run_installer "panel"
  else
    error "Installation aborted."
    exit 1
  fi
}

goodbye() {
  print_brake 62
  output "Hydrodactyl panel installation completed!"
  output ""
  output "Your panel should be accessible at: http${ASSUME_SSL:+s}://$FQDN"
  output ""
  output "Create your admin user:"
  output "  cd $INSTALL_DIR && docker compose exec panel php artisan p:user:make"
  output ""
  output "Installation directory: $INSTALL_DIR"
  output "Thank you for using Hydro-Installer."
  print_brake 62
}

main
goodbye
