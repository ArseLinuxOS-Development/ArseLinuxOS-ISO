# ArseLinuxOS

[![Maintenance](https://img.shields.io/maintenance/yes/2023.svg)]()


### A silly bum themed Linux distribution.

![Screenshot from 2023-11-13 01-10-11](https://github.com/ArseLinuxOS-Development/ArseLinuxOS-ISO/assets/17790730/1f11b969-d65c-47b2-83f0-5f5f70533aec)



This ISO is based on a modified Arch-ISO to provide Installation Environment for ArseLinuxOS. 
As you can imagine, this project is for fun and isn't meant to be used for anything serious, or rather, anything at all.

## Features
- i3-wm with Polybar
- ZFS on root with ZFS boot manager

# Installation
Only supports UEFI
1. Boot the ISO
2. `installer`


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

