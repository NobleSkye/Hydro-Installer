# Hydrodactyl Panel & Wings Automated Installer & Uninstaller

Unofficial installation scripts for [Hydrodactyl Panel](https://hydrodactyl.dev/) & [Wings](https://pterodactyl.io/wings/1.0/installing.html). Visit [gethydro.cc](https://gethydro.cc) for more info. This script is not associated with the official Hydrodactyl Project.

## Features

- Automatic installation of Docker Engine
- Automatic installation of Hydrodactyl Panel (Docker + Docker Compose)
- Automatic installation of Wings (Docker + Wings daemon)
- Install both Panel and Wings on the same machine
- Panel: (optional) automatic configuration of Let's Encrypt
- Wings: (optional) automatic configuration of Let's Encrypt
- Automatic configuration of firewall (UFW / firewalld)

## Supported installations

List of supported operating systems for Panel and Wings.

:white_check_mark: = Supported & Tested
:warning: = Supported but not tested
:red_square: = Not supported

| Operating System | Version | Supported          |
| ---------------- | ------- | ------------------ |
| Ubuntu           | 22.04   | :white_check_mark: |
|                  | 24.04   | :white_check_mark: |
|                  | 26.04   | :white_check_mark: |
| Debian           | 10      | :white_check_mark: |
|                  | 11      | :white_check_mark: |
|                  | 12      | :white_check_mark: |
|                  | 13      | :white_check_mark: |
| Rocky Linux      | 8       | :warning: |
|                  | 9       | :warning: |
| AlmaLinux        | 8       | :warning: |
|                  | 9       | :warning: |

Becuase Hyrodactyl is docker based support will vary per system

## Usage

Run the script as root. You will be prompted to choose between installing Docker only, the Panel, Wings, or both.

```bash
bash <(curl -fsSL https://gethydro.cc)
```

If `gethydro.cc` is unavailable, use the GitHub mirror:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/NobleSkye/Hydro-Installer/master/install.sh)
```

## Firewall

The installer can optionally configure UFW (Ubuntu/Debian) or firewalld (Rocky/AlmaLinux) and open the required ports automatically.

## Let's Encrypt

Both the Panel and Wings installers can optionally obtain and configure Let's Encrypt SSL certificates automatically.

## Special Mentions

This project is a fork that is inspired by [pterodactyl-installer/pterodactyl-installer](https://github.com/pterodactyl-installer/pterodactyl-installer) & [Pyrodactyl Installer](https://github.com/Muspelheim-Hosting/pyrodactyl-installer) 

## License

GNU General Public License v3.0
