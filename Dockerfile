FROM archlinux:latest

RUN pacman -Sy --noconfirm && \
    pacman -S --noconfirm --needed git archiso mkinitcpio-archiso rsync grub

WORKDIR /root
ENTRYPOINT ["/bin/bash", "/root/ArseLinuxOS-ISO/build.sh"]
