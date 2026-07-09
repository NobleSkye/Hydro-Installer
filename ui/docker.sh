#!/bin/bash

set -e

fn_exists() { declare -F "$1" >/dev/null; }
if ! fn_exists lib_loaded; then
  source /tmp/lib.sh || source <(curl -sSL "$GITHUB_URL/lib/lib.sh")
  ! fn_exists lib_loaded && echo "* ERROR: Could not load lib script" && exit 1
fi

main() {
  welcome

  output "This will install Docker using the official get.docker.com script."
  echo ""

  echo -n "* Proceed with Docker installation? (y/N): "
  read -r CONFIRM
  if [[ "$CONFIRM" =~ [Yy] ]]; then
    install_docker
    success "Docker installed successfully!"
  else
    error "Installation aborted."
    exit 1
  fi
}

main
