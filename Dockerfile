FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed git archiso mkinitcpio-archiso rsync grub && \
    pacman -Scc --noconfirm

WORKDIR /root
ENTRYPOINT ["/bin/bash", "/root/ArseLinuxOS-ISO/build.sh"]
