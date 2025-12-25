# ArseLinuxOS

[![Maintenance](https://img.shields.io/maintenance/yes/2025.svg)]()

### A silly bum themed Linux distribution.

![Screenshot from 2023-11-13 01-10-11](https://github.com/ArseLinuxOS-Development/ArseLinuxOS-ISO/assets/17790730/1f11b969-d65c-47b2-83f0-5f5f70533aec)

Based on Arch Linux with a modified archiso. This project is for fun and isn't meant to be used for anything serious.

## Features

- i3-wm with Polybar
- ZFS on root with encryption
- ZFSBootMenu bootloader
- TUI installer

## Installation

Requires UEFI.

1. Boot the ISO
2. Run `installer`
3. Follow the prompts
4. Reboot

## Package Repository

Custom packages are available from the [ArseLinux repo](https://github.com/ArseLinuxOS-Development/arselinux-repo).

Add to `/etc/pacman.conf`:

```ini
[arse-repo]
SigLevel = Never
Server = https://github.com/ArseLinuxOS-Development/arselinux-repo/releases/download/arselinux
```

## Building the ISO

```bash
git clone https://github.com/ArseLinuxOS-Development/ArseLinuxOS-ISO.git
cd ArseLinuxOS-ISO
./build
```

Or with Docker:

```bash
docker build -t arselinux-build . --no-cache
docker compose up
```
