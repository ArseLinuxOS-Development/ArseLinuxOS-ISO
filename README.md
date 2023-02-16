# ArseLinuxOS

[![Maintenance](https://img.shields.io/maintenance/yes/2023.svg)]()
[![Chat on Matrix](https://matrix.to/img/matrix-badge.svg)](https://app.element.io/#/room/#development:matrix.arselinux.org)


This ISO is based on a modified Arch-ISO to provide Installation Environment for ArseLinuxOS. 
As you can imagine, this project is for fun and isn't meant to be used for anything serious, or rather, anything at all.

# Features
- i3-wm

# Building

```
git clone https://github.com/ArseLinuxOS-Development/ArseLinuxOS-ISO.git && cd ArseLinuxOS-ISO
mkarchiso -v -w /archiso-tmp -o ../ .
```

## With Docker

(Edit `docker-compose.yml`) first to add your volume path
```
docker build -t arselinux-build . --no-cache
docker compose up
```

Once completed you will have an ISO image to test/boot. 


# TODO
- [ ] - Get a live DE working
- [ ] - Setup Calamares installer
- [ ] - Create a live environment so users have an immediate look at the distribution.
- [ ] - Setup a github action to automatically build ISO with mkarchiso on all branches.
- [x] - Probably need a custom repo for certain packages (no clue how involved this is)
