FROM archlinux:latest
RUN pacman -Sy --noconfirm
RUN pacman -Syu --noconfirm git reflector archiso mkinitcpio-archiso rsync
RUN reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
RUN git clone https://github.com/ArseLinuxOS-Development/ArseLinuxOS-ISO.git
ENTRYPOINT ["/bin/bash", "/root/ArseLinuxOS-ISO/build.sh"]
