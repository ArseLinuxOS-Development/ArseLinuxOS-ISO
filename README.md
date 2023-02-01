# ArseLinuxOS

[![Maintenance](https://img.shields.io/maintenance/yes/2023.svg)]()
[![Chat on Matrix](https://matrix.to/img/matrix-badge.svg)](https://app.element.io/#/room/#lounge:matrix.arselinux.org)

<img width="175" alt="iStock-1195419985-ai" src="https://user-images.githubusercontent.com/17790730/216143230-86a9d0b7-229a-416d-bf66-a86a80fada1e.png"> 
This ISO is based on a modified Arch-ISO to provide Installation Environment for ArseLinuxOS. 
As you can imagine, this project is for fun and isn't meant to be used for anything serious, or rather, anything at all.



# Building

```
git clone https://github.com/LiamAEdwards/ArseLinuxOS-ISO.git && cd ArseLinuxOS-ISO
mkarchiso -v -w /archiso-tmp -o ../ .
```

With Docker
```
docker build -t arselinux-build . --no-cache
docker run --privileged -it arselinux-build:latest /bin/bash
```
![image](https://user-images.githubusercontent.com/17790730/216143513-b9b610af-9312-4589-89f2-dc212c6eb957.png)

Once completed you will have an ISO image to test/boot. 


# TODO
- [ ] - Get a live DE working
- [ ] - Setup Calamares installer
- [x] - Create a logo
- [ ] - Probably need a custom repo for certain packages (no clue how involved this is)
- [ ] - Create a live environment so users have an immediate look at the distribution.
