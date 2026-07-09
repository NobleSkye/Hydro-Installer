# hydro-installer

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

| Operating System | Version | Supported          |
| ---------------- | ------- | ------------------ |
| Ubuntu           | 22.04   | :white_check_mark: |
|                  | 24.04   | :white_check_mark: |
|                  | 26.04   | :white_check_mark: |
| Debian           | 10      | :white_check_mark: |
|                  | 11      | :white_check_mark: |
|                  | 12      | :white_check_mark: |
|                  | 13      | :white_check_mark: |
| Rocky Linux      | 8       | :white_check_mark: |
|                  | 9       | :white_check_mark: |
| AlmaLinux        | 8       | :white_check_mark: |
|                  | 9       | :white_check_mark: |

## Usage

Run the script as root. You will be prompted to choose between installing Docker only, the Panel, Wings, or both.

(temp until dns resolves gethydro.cc)
```bash
bash <(curl -sSL https://raw.githubusercontent.com/NobleSkye/Hydro-Installer/master/install.sh)
```

Once gethydro.cc is live, you'll also be able to use:

```bash
bash <(curl -sSL https://gethydro.cc)
```

## Firewall

The installer can optionally configure UFW (Ubuntu/Debian) or firewalld (Rocky/AlmaLinux) and open the required ports automatically.

## Let's Encrypt

Both the Panel and Wings installers can optionally obtain and configure Let's Encrypt SSL certificates automatically.

## License

GNU General Public License v3.0
