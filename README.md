# ArseLinuxOS

[![Maintenance](https://img.shields.io/maintenance/yes/2023.svg)]() 
[![Chat on Matrix](https://matrix.to/img/matrix-badge.svg)](https://app.element.io/#/room/#lounge:matrix.arselinux.org)


This ISO is based on a modified Arch-ISO to provide Installation Environment for ArseLinuxOS.

As you can imagine, this project is for fun and isn't meant to be used for anything serious, or rather, anything at all.



# Development

I use docker to make the development process more streamlined. 

To get involved

```
docker build --no-cache -t arselinux-build .
docker volume create arselinux-volume
docker run -it --privileged=true -v arselinux-volume:/root/ arselinux-build:latest bash
```

Inside the container you can make your changes, build the ISO and if all looks good, push the changes to Github.

# Building

```
git clone https://github.com/LiamAEdwards/ArseLinuxOS-ISO.git && cd ArseLinuxOS-ISO
mkarchiso -v -w /archiso-tmp -o ../ .
```

Once completed you will have an ISO image. 


# TODO
- [ ] - Get a live DE working
- [ ] - Setup Calamares installer
- [ ] - Create a logo
- [ ] - Probably need a custom repo for certain packages (no clue how involved this is)
- [ ] - Create a live environment so users have an immediate look at the distribution.


