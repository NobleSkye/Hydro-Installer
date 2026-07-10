#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Project 'hydro-installer'                                                          #
#                                                                                    #
# Copyright (C) 2025, Hydrodactyl                                                    #
#                                                                                    #
#   This program is free software: you can redistribute it and/or modify             #
#   it under the terms of the GNU General Public License as published by             #
#   the Free Software Foundation, either version 3 of the License, or                #
#   (at your option) any later version.                                              #
#                                                                                    #
#   This program is distributed in the hope that it will be useful,                  #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of                   #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                    #
#   GNU General Public License for more details.                                     #
#                                                                                    #
#   You should have received a copy of the GNU General Public License                #
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.           #
#                                                                                    #
######################################################################################

# ------------------ Variables ----------------- #

# Versioning
export GITHUB_SOURCE=${GITHUB_SOURCE:-master}
export SCRIPT_RELEASE=${SCRIPT_RELEASE:-canary}

# Path
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# OS
export OS=""
export OS_VER_MAJOR=""
export CPU_ARCHITECTURE=""
export ARCH=""
export SUPPORTED=false

# download URLs
export HYDRO_COMPOSE_URL="https://raw.githubusercontent.com/blueprintframework/hydrodactyl/main/docker-compose.example.yml"
export WINGS_DL_BASE_URL="https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_"
export GITHUB_BASE_URL=${GITHUB_BASE_URL:-"https://raw.githubusercontent.com/NobleSkye/Hydro-Installer"}
export GITHUB_URL="$GITHUB_BASE_URL/$GITHUB_SOURCE"

# Local paths (set when sourced locally)
export HYDRO_INSTALLER_DIR=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
if [ -f "$PARENT_DIR/install.sh" ]; then
  export HYDRO_INSTALLER_DIR="$PARENT_DIR"
fi

# System Requirements
export MIN_CPU_CORES=2
export MIN_RAM_MB=2048
export MIN_DISK_GB=20
export REC_CPU_CORES=4
export REC_RAM_MB=4096
export REC_DISK_GB=50

# Colors
export COLOR_DARK_BLUE='\033[38;5;24m'
export COLOR_BLUE='\033[38;5;27m'
export COLOR_LIGHT_BLUE='\033[38;5;39m'
export COLOR_CYAN='\033[38;5;51m'
export COLOR_YELLOW='\033[1;33m'
export COLOR_GREEN='\033[0;32m'
export COLOR_RED='\033[0;31m'
export COLOR_ORANGE='\033[38;5;214m'
export COLOR_GRAY='\033[38;5;240m'
export COLOR_NC='\033[0m'

# Water gradient colors (top to bottom) - deep blue to cyan
export GRADIENT_1='\033[38;5;17m'
export GRADIENT_2='\033[38;5;18m'
export GRADIENT_3='\033[38;5;20m'
export GRADIENT_4='\033[38;5;21m'
export GRADIENT_5='\033[38;5;24m'
export GRADIENT_6='\033[38;5;27m'
export GRADIENT_7='\033[38;5;31m'
export GRADIENT_8='\033[38;5;33m'
export GRADIENT_9='\033[38;5;39m'
export GRADIENT_10='\033[38;5;45m'
export GRADIENT_11='\033[38;5;51m'

# email input validation regex
email_regex="^(([A-Za-z0-9]+((\.|\-|\_|\+)?[A-Za-z0-9]?)*[A-Za-z0-9]+)|[A-Za-z0-9]+)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$"

# Charset used to generate random passwords
password_charset='A-Za-z0-9!"#%&()*+,-./:;<=>?@[\]^_`{|}~'

# --------------------- Lib -------------------- #

lib_loaded() {
  return 0
}

# -------------- Visual functions -------------- #

output() {
  echo -e "* $1"
}

success() {
  echo ""
  output "${COLOR_GREEN}SUCCESS${COLOR_NC}: $1"
  echo ""
}

error() {
  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1" 1>&2
  echo ""
}

warning() {
  echo ""
  output "${COLOR_YELLOW}WARNING${COLOR_NC}: $1"
  echo ""
}

print_brake() {
  local char="${2:-─}"
  for ((n = 0; n < $1; n++)); do
    echo -n "$char"
  done
  echo ""
}

print_list() {
  print_brake 30
  for word in $1; do
    output "$word"
  done
  print_brake 30
  echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

print_header() {
  clear 2>/dev/null || true
  echo ""
  echo -e "${GRADIENT_1}    ╔══════════════════════════════════════════════════════════════════════════════════════╗"
  echo -e "${GRADIENT_2}    ║                                                                                      ║"
  echo -e "${GRADIENT_3}    ║  ██╗  ██╗██╗   ██╗██████╗ ██████╗  ██████╗    ██╗███╗   ██╗███████╗████████╗ █████╗   ║"
  echo -e "${GRADIENT_4}    ║  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔═══██╗   ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗  ║"
  echo -e "${GRADIENT_5}    ║  ███████║ ╚████╔╝ ██║  ██║██████╔╝██║   ██║   ██║██╔██╗ ██║███████╗   ██║   ███████║  ║"
  echo -e "${GRADIENT_6}    ║  ██╔══██║  ╚██╔╝  ██║  ██║██╔══██╗██║   ██║   ██║██║╚██╗██║╚════██║   ██║   ██╔══██║  ║"
  echo -e "${GRADIENT_7}    ║  ██║  ██║   ██║   ██████╔╝██║  ██║╚██████╔╝   ██║██║ ╚████║███████║   ██║   ██║  ██║  ║"
  echo -e "${GRADIENT_8}    ║  ╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝  ║"
  echo -e "${GRADIENT_9}    ║                                                                                      ║"
  echo -e "${GRADIENT_10}    ║                         Hydro-Installer Management Suite                             ║"
  echo -e "${GRADIENT_11}    ╚══════════════════════════════════════════════════════════════════════════════════════╝"
  echo -e "${COLOR_NC}"
  echo -e "    ${COLOR_CYAN}Version:${COLOR_NC} ${SCRIPT_RELEASE}  ${COLOR_CYAN}|${COLOR_NC}  ${COLOR_CYAN}By:${COLOR_NC} Hydrodactyl"
  echo ""
}

welcome() {
  print_header

  local cpu_cores=$(nproc 2>/dev/null || echo "1")
  local ram_human=$(free -h 2>/dev/null | awk '/^Mem:/{print $2}' || echo "Unknown")
  local disk_human=$(df -h / 2>/dev/null | awk 'NR==2 {print $4}' || echo "Unknown")
  local swap_mb=$(free -m 2>/dev/null | awk '/^Swap:/{print $2}' || echo "0")
  local swap_human=$(free -h 2>/dev/null | awk '/^Swap:/{print $2}' || echo "0")

  echo -e "  ${COLOR_CYAN}Operating System:${COLOR_NC} $OS $OS_VER_MAJOR ($ARCH)"
  echo -e "  ${COLOR_CYAN}System Resources:${COLOR_NC} ${cpu_cores} cores, ${ram_human} RAM, ${disk_human} disk, ${swap_human} swap"
  echo ""

  if [ -d "/srv/hydrodactyl" ]; then
    echo -e "  ${COLOR_GREEN}✓${COLOR_NC} Panel installed"
  else
    echo -e "  ${COLOR_RED}✗${COLOR_NC} Panel not installed"
  fi

  if [ -f "/usr/local/bin/wings" ]; then
    echo -e "  ${COLOR_GREEN}✓${COLOR_NC} Wings installed"
  else
    echo -e "  ${COLOR_RED}✗${COLOR_NC} Wings not installed"
  fi

  echo ""
  print_brake 70
  echo ""
}

# ---------------- Lib functions --------------- #

valid_email() {
  [[ $1 =~ ${email_regex} ]]
}

gen_passwd() {
  local length=$1
  local password=""
  while [ ${#password} -lt "$length" ]; do
    password=$(echo "$password""$(head -c 100 /dev/urandom | LC_ALL=C tr -dc "$password_charset")" | fold -w "$length" | head -n 1)
  done
  echo "$password"
}

# --------------- Package Manager -------------- #

update_repos() {
  local args=""
  
  [[ "$1" == true ]] && args="-qq"

  case "$OS" in
    ubuntu | debian)
      output "Updating package repositories..."
      if ! apt-get update -y $args; then
        error "Failed to update repositories."
        return 1
      fi
      ;;
    rocky | almalinux)
      output "Skipping repository update (handled automatically on $OS)."
      ;;
    *)
      warning "Unsupported OS: $OS — skipping repository update."
      ;;
  esac
}

install_packages() {
  local args=""
  if [[ $2 == true ]]; then
    case "$OS" in
    ubuntu | debian) args="-qq" ;;
    *) args="-q" ;;
    esac
  fi

  case "$OS" in
  ubuntu | debian)
    eval apt-get -y $args install "$1"
    ;;
  rocky | almalinux)
    eval dnf -y $args install "$1"
    ;;
  esac
}

# ------------ User input functions ------------ #

required_input() {
  local __resultvar=$1
  local result=''

  while [ -z "$result" ]; do
    echo -n "* ${2}"
    read -r result

    if [ -z "${3}" ]; then
      [ -z "$result" ] && result="${4}"
    else
      [ -z "$result" ] && error "${3}"
    fi
  done

  eval "$__resultvar="'$result'""
}

email_input() {
  local __resultvar=$1
  local result=''

  while ! valid_email "$result"; do
    echo -n "* ${2}"
    read -r result

    valid_email "$result" || error "${3}"
  done

  eval "$__resultvar="'$result'""
}

password_input() {
  local __resultvar=$1
  local result=''
  local default="$4"

  while [ -z "$result" ]; do
    echo -n "* ${2}"

    while IFS= read -r -s -n1 char; do
      [[ -z $char ]] && {
        printf '\n'
        break
      }
      if [[ $char == $'\x7f' ]]; then
        if [ -n "$result" ]; then
          [[ -n $result ]] && result=${result%?}
          printf '\b \b'
        fi
      else
        result+=$char
        printf '*'
      fi
    done
    [ -z "$result" ] && [ -n "$default" ] && result="$default"
    [ -z "$result" ] && error "${3}"
  done

  eval "$__resultvar="'$result'""
}

# ------------------ Firewall ------------------ #

ask_firewall() {
  local __resultvar=$1

  case "$OS" in
  ubuntu | debian)
    echo -e -n "* Do you want to automatically configure UFW (firewall)? (y/N): "
    read -r CONFIRM_UFW

    if [[ "$CONFIRM_UFW" =~ [Yy] ]]; then
      eval "$__resultvar="'true'""
    fi
    ;;
  rocky | almalinux)
    echo -e -n "* Do you want to automatically configure firewall-cmd (firewall)? (y/N): "
    read -r CONFIRM_FIREWALL_CMD

    if [[ "$CONFIRM_FIREWALL_CMD" =~ [Yy] ]]; then
      eval "$__resultvar="'true'""
    fi
    ;;
  esac
}

install_firewall() {
  case "$OS" in
  ubuntu | debian)
    output ""
    output "Installing Uncomplicated Firewall (UFW)"

    if ! [ -x "$(command -v ufw)" ]; then
      update_repos true
      install_packages "ufw" true
    fi

    ufw --force enable
    success "Enabled Uncomplicated Firewall (UFW)"
    ;;
  rocky | almalinux)
    output ""
    output "Installing FirewallD"

    if ! [ -x "$(command -v firewall-cmd)" ]; then
      install_packages "firewalld" true
    fi

    systemctl --now enable firewalld >/dev/null
    success "Enabled FirewallD"
    ;;
  esac
}

firewall_allow_ports() {
  case "$OS" in
  ubuntu | debian)
    for port in $1; do
      if [[ "$port" == *":"* ]]; then
        ufw allow "$port/tcp"
        ufw allow "$port/udp"
      else
        ufw allow "$port"
      fi
    done
    ufw --force reload
    ;;
  rocky | almalinux)
    for port in $1; do
      if [[ "$port" == *":"* ]]; then
        firewall-cmd --zone=public --add-port="$port"/tcp --permanent
        firewall-cmd --zone=public --add-port="$port"/udp --permanent
      else
        firewall-cmd --zone=public --add-port="$port"/tcp --permanent
      fi
    done
    firewall-cmd --reload -q
    ;;
  esac
}

# --------------- Script loading --------------- #

update_lib_source() {
  GITHUB_URL="$GITHUB_BASE_URL/$GITHUB_SOURCE"
  rm -rf /tmp/lib.sh
  curl -sSL -o /tmp/lib.sh "$GITHUB_URL/lib/lib.sh"
  # shellcheck source=lib/lib.sh
  source /tmp/lib.sh
}

run_installer() {
  if [ -n "$HYDRO_INSTALLER_DIR" ]; then
    cp "$HYDRO_INSTALLER_DIR/lib/lib.sh" /tmp/lib.sh
    bash "$HYDRO_INSTALLER_DIR/installers/$1.sh"
  else
    bash <(curl -sSL "$GITHUB_URL/installers/$1.sh")
  fi
}

run_ui() {
  if [ -n "$HYDRO_INSTALLER_DIR" ]; then
    cp "$HYDRO_INSTALLER_DIR/lib/lib.sh" /tmp/lib.sh
    bash "$HYDRO_INSTALLER_DIR/ui/$1.sh"
  else
    bash <(curl -sSL "$GITHUB_URL/ui/$1.sh")
  fi
}

# --------------- Docker helpers --------------- #

install_docker() {
  if [ -x "$(command -v docker)" ]; then
    output "Docker is already installed, skipping."
    return 0
  fi

  output "Installing Docker using get.docker.com..."
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sh /tmp/get-docker.sh
  rm -f /tmp/get-docker.sh

  systemctl enable docker
  systemctl start docker

  success "Docker installed successfully!"
}

# ---------------- System checks --------------- #

# wings virtualization check
check_virt() {
  output "Installing virt-what..."

  update_repos true
  install_packages "virt-what" true

  export PATH="$PATH:/sbin:/usr/sbin"

  virt_serv=$(virt-what)

  case "$virt_serv" in
  *openvz* | *lxc*)
    warning "Unsupported type of virtualization detected. Please consult with your hosting provider whether your server can run Docker or not. Proceed at your own risk."
    echo -e -n "* Are you sure you want to proceed? (y/N): "
    read -r CONFIRM_PROCEED
    if [[ ! "$CONFIRM_PROCEED" =~ [Yy] ]]; then
      error "Installation aborted!"
      exit 1
    fi
    ;;
  *)
    [ "$virt_serv" != "" ] && warning "Virtualization: $virt_serv detected."
    ;;
  esac

  if uname -r | grep -q "xxxx"; then
    error "Unsupported kernel detected."
    exit 1
  fi

  success "System is compatible with docker"
}

# ------------------ System Resource Functions ----------------- #

get_cpu_cores() {
  nproc 2>/dev/null || echo "1"
}

get_ram_mb() {
  free -m 2>/dev/null | awk '/^Mem:/{print $2}' || echo "0"
}

get_ram_human() {
  free -h 2>/dev/null | awk '/^Mem:/{print $2}' || echo "Unknown"
}

get_disk_gb() {
  df -BG / 2>/dev/null | awk 'NR==2 {gsub(/G/,""); print $4}' || echo "0"
}

get_disk_human() {
  df -h / 2>/dev/null | awk 'NR==2 {print $4}' || echo "Unknown"
}

get_swap_mb() {
  local swap_mb=$(free -m 2>/dev/null | awk '/^Swap:/{print $2}')
  echo "${swap_mb:-0}"
}

get_swap_human() {
  free -h 2>/dev/null | awk '/^Swap:/{print $2}' || echo "0"
}

check_system_resources() {
  local cpu_cores=$(get_cpu_cores)
  local ram_mb=$(get_ram_mb)
  local disk_gb=$(get_disk_gb)
  local below_minimum=false
  local warnings=()

  if [ "$cpu_cores" -lt "$MIN_CPU_CORES" ]; then
    warnings+=("CPU cores: $cpu_cores (minimum: $MIN_CPU_CORES)")
    below_minimum=true
  fi

  if [ "$ram_mb" -lt "$MIN_RAM_MB" ]; then
    warnings+=("RAM: ${ram_mb}MB / $(get_ram_human) (minimum: ${MIN_RAM_MB}MB)")
    below_minimum=true
  fi

  if [ "$disk_gb" -lt "$MIN_DISK_GB" ]; then
    warnings+=("Disk space: ${disk_gb}GB (minimum: ${MIN_DISK_GB}GB)")
    below_minimum=true
  fi

  echo ""
  output "${COLOR_CYAN}System Resources${COLOR_NC}"
  print_brake 40
  output "CPU Cores:        $cpu_cores"
  output "RAM:              $(get_ram_human) (${ram_mb}MB)"
  output "Disk (root):      $(get_disk_human) (${disk_gb}GB)"
  output "Swap:             $(get_swap_human)"
  print_brake 40

  if [ "$below_minimum" == true ]; then
    echo ""
    warning "System is below minimum requirements:"
    for warn in "${warnings[@]}"; do
      output "  - $warn"
    done
    return 1
  elif [ "$cpu_cores" -lt "$REC_CPU_CORES" ] || [ "$ram_mb" -lt "$REC_RAM_MB" ]; then
    echo ""
    info "System meets minimum but is below recommended:"
    [ "$cpu_cores" -lt "$REC_CPU_CORES" ] && output "  - CPU: $cpu_cores cores (recommended: $REC_CPU_CORES)"
    [ "$ram_mb" -lt "$REC_RAM_MB" ] && output "  - RAM: $(get_ram_human) (recommended: 4GB)"
    [ "$disk_gb" -lt "$REC_DISK_GB" ] && output "  - Disk: ${disk_gb}GB (recommended: ${REC_DISK_GB}GB)"
    return 0
  else
    success "System meets recommended requirements!"
    return 0
  fi
}

setup_swap() {
  local swap_size="${1:-2G}"
  local swap_file="/swapfile"

  output "Setting up ${swap_size} swap file..."

  if swapon --show=NAME,TYPE | grep -q "$swap_file"; then
    warning "Swap file already exists at $swap_file"
    return 1
  fi

  if [[ ! "$swap_size" =~ ^[0-9]+[MG]$ ]]; then
    error "Invalid swap size format: $swap_size"
    return 1
  fi

  if command -v fallocate >/dev/null 2>&1; then
    if ! fallocate -l "$swap_size" "$swap_file" 2>/dev/null; then
      local size_mb
      if [[ "$swap_size" =~ G$ ]]; then
        size_mb=$((${swap_size%G} * 1024))
      else
        size_mb=${swap_size%M}
      fi
      dd if=/dev/zero of="$swap_file" bs=1M count="$size_mb" status=progress
    fi
  else
    local size_mb
    if [[ "$swap_size" =~ G$ ]]; then
      size_mb=$((${swap_size%G} * 1024))
    else
      size_mb=${swap_size%M}
    fi
    dd if=/dev/zero of="$swap_file" bs=1M count="$size_mb" status=progress
  fi

  chmod 600 "$swap_file"
  mkswap "$swap_file"
  swapon "$swap_file"

  if ! grep -q "^$swap_file" /etc/fstab; then
    echo "$swap_file swap swap defaults 0 0" >> /etc/fstab
  fi

  sysctl vm.swappiness=10 2>/dev/null || true
  success "Swap configured: $(get_swap_human)"
  return 0
}

info() {
  echo -e "* ${COLOR_BLUE}INFO${COLOR_NC}: $1"
}

# ------------------ Boolean Input ----------------- #

bool_input() {
  local __resultvar=$1
  local prompt="$2"
  local default="${3:-n}"
  local result=""

  while [[ "$result" != "y" && "$result" != "n" ]]; do
    echo -n "* $prompt [y/N]: "
    read -r result
    result=$(echo "$result" | tr '[:upper:]' '[:lower:]')
    [ -z "$result" ] && result="$default"
  done

  eval "$__resultvar=\"$result\""
}

# ------------------ Game Ports Firewall ----------------- #

configure_firewall_rules() {
  local http="${1:-true}"
  local https="${2:-true}"
  local wings="${3:-false}"

  output "Configuring firewall rules..."

  local ports="22"
  [ "$http" == true ] && ports="$ports 80"
  [ "$https" == true ] && ports="$ports 443"
  [ "$wings" == true ] && ports="$ports 8080 2022"

  output "Opening game server ports..."
  output "  - 25565-25665 (Minecraft)"
  output "  - 27015-27150 (Source Engine)"
  output "  - 7777-8000 (Unreal Engine)"
  output "  - 28015-28025 (Rust)"
  output "  - 2456-2466 (Valheim)"
  output "  - 30120-30130 (FiveM/GTA)"

  ports="$ports 25565:25665 27015:27150 7777:8000 28015:28025 2456:2466 30120:30130"
  firewall_allow_ports "$ports"
  success "Firewall configured with game ports"
}

ask_game_ports() {
  local __resultvar=$1
  local confirm=""

  echo ""
  output "Configure game server ports in firewall?"
  output "This opens ports for: Minecraft, Source Engine, Unreal Engine, Rust, Valheim, FiveM"

  while [[ "$confirm" != "y" && "$confirm" != "n" ]]; do
    echo -n "* Configure game ports? [y/N]: "
    read -r confirm
    confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
    [ -z "$confirm" ] && confirm="n"
  done

  [[ "$confirm" == "y" ]] && eval "$__resultvar=true" || eval "$__resultvar=false"
}

# ------------------ Health Check Functions ----------------- #

check_panel_health() {
  local has_errors=false

  print_flame "Panel Health Check"

  output "Checking panel directory..."
  if [ ! -d "/srv/hydrodactyl" ]; then
    error "Panel directory not found at /srv/hydrodactyl"
    has_errors=true
  else
    output "  ${COLOR_GREEN}✓${COLOR_NC} Panel directory exists"
  fi

  if [ -f "/srv/hydrodactyl/docker-compose.yml" ]; then
    output "  ${COLOR_GREEN}✓${COLOR_NC} docker-compose.yml found"
  else
    warning "  docker-compose.yml not found"
    has_errors=true
  fi

  output "Checking Docker..."
  if systemctl is-active --quiet docker 2>/dev/null; then
    output "  ${COLOR_GREEN}✓${COLOR_NC} Docker is running"
  else
    warning "  Docker is not running"
    has_errors=true
  fi

  output "Checking panel containers..."
  if command -v docker >/dev/null 2>&1; then
    local running=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -c hydrodactyl || true)
    if [ "$running" -gt 0 ]; then
      output "  ${COLOR_GREEN}✓${COLOR_NC} $running hydrodactyl container(s) running"
    else
      warning "  No hydrodactyl containers running"
      has_errors=true
    fi
  fi

  echo ""
  if [ "$has_errors" == true ]; then
    warning "Panel health check completed with issues"
    return 1
  else
    success "Panel health check passed!"
    return 0
  fi
}

check_wings_health() {
  local has_errors=false

  print_flame "Wings Health Check"

  output "Checking Wings binary..."
  if [ -f "/usr/local/bin/wings" ]; then
    output "  ${COLOR_GREEN}✓${COLOR_NC} Wings binary found"
  else
    error "  Wings binary not found"
    has_errors=true
  fi

  output "Checking Wings config..."
  if [ -f "/etc/pterodactyl/config.yml" ]; then
    output "  ${COLOR_GREEN}✓${COLOR_NC} Wings config found"
  else
    warning "  Wings config not found"
    has_errors=true
  fi

  output "Checking Wings service..."
  if systemctl is-active --quiet wings 2>/dev/null; then
    output "  ${COLOR_GREEN}✓${COLOR_NC} Wings is running"
  else
    warning "  Wings is not running"
    has_errors=true
  fi

  output "Checking Docker..."
  if systemctl is-active --quiet docker 2>/dev/null; then
    output "  ${COLOR_GREEN}✓${COLOR_NC} Docker is running"
  else
    warning "  Docker is not running"
    has_errors=true
  fi

  echo ""
  if [ "$has_errors" == true ]; then
    warning "Wings health check completed with issues"
    return 1
  else
    success "Wings health check passed!"
    return 0
  fi
}

check_both_health() {
  check_panel_health
  echo ""
  check_wings_health
}

check_system_health() {
  print_flame "System Health Check"
  check_system_resources
}

# ------------------ Repair Functions ----------------- #

fix_panel_permissions() {
  print_flame "Fixing Panel Permissions"

  if [ ! -d "/srv/hydrodactyl" ]; then
    error "Panel installation not found at /srv/hydrodactyl"
    return 1
  fi

  output "Setting ownership..."
  chown -R root:root /srv/hydrodactyl 2>/dev/null || true
  output "Setting directory permissions..."
  find /srv/hydrodactyl -type d -exec chmod 755 {} \; 2>/dev/null || true
  find /srv/hydrodactyl -type f -exec chmod 644 {} \; 2>/dev/null || true

  success "Panel permissions fixed"
  return 0
}

fix_wings_permissions() {
  print_flame "Fixing Wings Permissions"

  if [ -f "/usr/local/bin/wings" ]; then
    output "Setting binary permissions..."
    chmod +x /usr/local/bin/wings
    output "  ${COLOR_GREEN}✓${COLOR_NC} Wings binary is executable"
  else
    warning "Wings binary not found"
  fi

  if [ -d "/etc/pterodactyl" ]; then
    output "Setting config permissions..."
    chmod -R 755 /etc/pterodactyl 2>/dev/null || true
    output "  ${COLOR_GREEN}✓${COLOR_NC} Config permissions set"
  fi

  if [ -d "/var/lib/pterodactyl" ]; then
    output "Setting data directory permissions..."
    chown -R root:root /var/lib/pterodactyl 2>/dev/null || true
    output "  ${COLOR_GREEN}✓${COLOR_NC} Data directory permissions set"
  fi

  success "Wings permissions fixed"
  return 0
}

restart_services() {
  print_flame "Restarting Services"

  output "Restarting Docker..."
  systemctl restart docker 2>/dev/null || warning "Failed to restart Docker"

  if [ -f "/srv/hydrodactyl/docker-compose.yml" ]; then
    output "Restarting Panel containers..."
    cd /srv/hydrodactyl && docker compose restart 2>/dev/null || warning "Failed to restart panel containers"
  fi

  if [ -f "/usr/local/bin/wings" ]; then
    output "Restarting Wings..."
    systemctl restart wings 2>/dev/null || warning "Failed to restart Wings"
  fi

  success "Services restarted"
  return 0
}

run_all_fixes() {
  print_flame "Running All Fixes"

  warning "This will run all repair operations. Some services may be restarted."
  output "Press Enter to continue or Ctrl+C to cancel..."
  read -r

  fix_panel_permissions || true
  echo ""
  fix_wings_permissions || true
  echo ""
  restart_services || true

  success "All fixes completed!"
  output "Press Enter to return to the menu..."
  read -r
}

print_flame() {
  local message="$1"
  echo ""
  echo -e "${COLOR_CYAN}  $message${COLOR_NC}"
  echo ""
}

# ------------------ Auto-Updater Functions ----------------- #

install_auto_updater() {
  local component="$1"
  local repo="$2"
  local interval="${3:-daily}"

  print_flame "Installing Auto-Updater for $component"

  mkdir -p /etc/hydrodactyl

  local script_path="/usr/local/bin/hydro-auto-update-${component}.sh"
  cat > "$script_path" << 'EOF'
#!/bin/bash
# Auto-updater for Hydrodactyl components
set -e

EOF

  echo "COMPONENT=\"$component\"" >> "$script_path"
  echo "REPO=\"$repo\"" >> "$script_path"
  echo "LOG_FILE=\"/var/log/hydro-${component}-auto-update.log\"" >> "$script_path"

  if [ "$component" == "panel" ]; then
    cat >> "$script_path" << 'EOF'
mkdir -p "$(dirname "$LOG_FILE")"
echo "[$(date)] Checking for panel updates..." >> "$LOG_FILE"

cd /srv/hydrodactyl
docker compose pull 2>/dev/null || true
docker compose up -d --no-deps 2>/dev/null || true
echo "[$(date)] Panel update check completed" >> "$LOG_FILE"
EOF
  elif [ "$component" == "wings" ]; then
    cat >> "$script_path" << 'EOF'
mkdir -p "$(dirname "$LOG_FILE")"
echo "[$(date)] Checking for Wings updates..." >> "$LOG_FILE"

curl -fsSL -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 2>/dev/null && \
  chmod +x /usr/local/bin/wings && \
  systemctl restart wings && \
  echo "[$(date)] Wings updated successfully" >> "$LOG_FILE" || \
  echo "[$(date)] Wings update check completed (no update needed)" >> "$LOG_FILE"
EOF
  fi

  chmod +x "$script_path"

  # Install systemd timer
  local service_path="/etc/systemd/system/hydro-auto-update-${component}.service"
  local timer_path="/etc/systemd/system/hydro-auto-update-${component}.timer"

  cat > "$service_path" << EOF
[Unit]
Description=Hydrodactyl $component Auto-Update
After=docker.service

[Service]
Type=oneshot
ExecStart=$script_path
EOF

  cat > "$timer_path" << EOF
[Unit]
Description=Hydrodactyl $component Auto-Update Timer

[Timer]
OnCalendar=$interval
Persistent=true

[Install]
WantedBy=timers.target
EOF

  systemctl daemon-reload
  systemctl enable --now "hydro-auto-update-${component}.timer"

  success "$component auto-updater installed (${interval})"
}

remove_auto_updater() {
  local component="$1"

  output "Removing $component auto-updater..."

  systemctl stop "hydro-auto-update-${component}.timer" 2>/dev/null || true
  systemctl disable "hydro-auto-update-${component}.timer" 2>/dev/null || true
  rm -f "/etc/systemd/system/hydro-auto-update-${component}.service"
  rm -f "/etc/systemd/system/hydro-auto-update-${component}.timer"
  rm -f "/usr/local/bin/hydro-auto-update-${component}.sh"
  systemctl daemon-reload

  success "$component auto-updater removed"
}

# Exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  error "This script must be executed with root privileges."
  exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$(echo "$ID" | awk '{print tolower($0)}')
  OS_VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
  OS=$(lsb_release -si | awk '{print tolower($0)}')
  OS_VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
  . /etc/lsb-release
  OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
  OS_VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
  OS="debian"
  OS_VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
  OS="SuSE"
  OS_VER="?"
elif [ -f /etc/redhat-release ]; then
  OS="Red Hat/CentOS"
  OS_VER="?"
else
  OS=$(uname -s)
  OS_VER=$(uname -r)
fi

OS=$(echo "$OS" | awk '{print tolower($0)}')
OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
CPU_ARCHITECTURE=$(uname -m)

case "$CPU_ARCHITECTURE" in
x86_64)
  ARCH=amd64
  ;;
arm64 | aarch64)
  ARCH=arm64
  ;;
*)
  error "Only x86_64 and arm64 are supported!"
  exit 1
  ;;
esac

case "$OS" in
ubuntu)
  [ "$OS_VER_MAJOR" == "22" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "24" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "26" ] && SUPPORTED=true
  export DEBIAN_FRONTEND=noninteractive
  ;;
debian)
  [ "$OS_VER_MAJOR" == "10" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "11" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "12" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "13" ] && SUPPORTED=true
  export DEBIAN_FRONTEND=noninteractive
  ;;
rocky | almalinux)
  [ "$OS_VER_MAJOR" == "8" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "9" ] && SUPPORTED=true
  ;;
*)
  SUPPORTED=false
  ;;
esac

if [ "$SUPPORTED" == false ]; then
  output "$OS $OS_VER is not supported"
  error "Unsupported OS"
  exit 1
fi
