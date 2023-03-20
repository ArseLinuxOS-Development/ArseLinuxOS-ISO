# ArseLinuxOS

[![Maintenance](https://img.shields.io/maintenance/yes/2023.svg)]()
[![Chat on Matrix](https://matrix.to/img/matrix-badge.svg)](https://matrix.to/#/#arselinux-dev:envs.net)

### A silly bum themed Linux distribution.


<img width="960" alt="desktop" src="https://user-images.githubusercontent.com/17790730/226481456-89aa0461-368a-4850-a3d2-6b4402612184.png">

This ISO is based on a modified Arch-ISO to provide Installation Environment for ArseLinuxOS. 
As you can imagine, this project is for fun and isn't meant to be used for anything serious, or rather, anything at all.

## Features
- i3-wm with Polybar
- ZFS on root with ZFS boot manager

# Installing the ISO
Only supports UEFI
1. Boot the ISO
2. `chmod +x installer.sh`
3. `./installer`



# Development

## Building

```
git clone https://github.com/ArseLinuxOS-Development/ArseLinuxOS-ISO.git && cd ArseLinuxOS-ISO
./build
```

## With Docker

```
docker build -t arselinux-build . --no-cache
docker compose up
```

Once completed you will have an ISO image to test/boot. 


# TODO
- [ ] - Create a customised live environment
- [ ] - Need a suitable desktop background
