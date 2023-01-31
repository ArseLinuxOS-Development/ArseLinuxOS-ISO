# ArseLinuxOS

[![Maintenance](https://img.shields.io/maintenance/yes/2023.svg)]()
[![Chat on Matrix](https://matrix.to/img/matrix-badge.svg)](https://app.element.io/#/room/#lounge:matrix.arselinux.org)

This ISO is based on a modified Arch-ISO to provide Installation Environment for ArseLinuxOS.

As you can imagine, this project is for fun and isn't meant to be used for anything serious, or rather, anything at all.

```
  ___                _     _                  
 / _ \              | |   (_)                 
/ /_\ \_ __ ___  ___| |    _ _ __  _   ___  __
|  _  | '__/ __|/ _ \ |   | | '_ \| | | \ \/ /
| | | | |  \__ \  __/ |___| | | | | |_| |>  < 
\_| |_/_|  |___/\___\_____/_|_| |_|\__,_/_/\_\

⣰⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⢠⣦⠀⠀⠀⠀
⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣤⡀⠀⠀⢠⠟⠁⠀⢀⣀⡀
⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⡀⢠⣶⠄⠀⠀⠀⠙⢷⣄⠀⠈⠀⣠⣴⠿⠛⠁
⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⠁⠀⠀⠀⠀⠀⠈⢿⡄⠀⠀⠀⠀⢀⣀⣀         
⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣇⠀⠀⠀⠀⠀⠀⢸⣷⠀⠀⠀⠈⠉⠛⠛
⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⢽⡂⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀
⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⠁⠀⠀⠀⠀⢀⣾⠇⠀⠀⠀⠀⠀⠀⠀
⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⠃⠀⠀⠀⠀⣠⣾⠋⠀⠀⠀⠀⠀⠀⠀⠀
⣿⡇⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣿⣧⣤⣤⣤⣶⠾⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢿⡇⠀⠀⠀⠸⠿⠿⠟⠛⠉⢹⡇⠀⠀  ⠀⠀⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠘⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠑⠀⠀⠀⠀⠀⠀⠒
```

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

Once completed you will have an ISO image to test/boot. 


# TODO
- [ ] - Get a live DE working
- [ ] - Setup Calamares installer
- [x] - Create a logo
- [ ] - Probably need a custom repo for certain packages (no clue how involved this is)
- [ ] - Create a live environment so users have an immediate look at the distribution.
