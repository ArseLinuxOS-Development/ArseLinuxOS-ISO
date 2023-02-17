FROM archlinux:latest
RUN pacman -Syu --noconfirm git reflector archiso mkinitcpio-archiso
RUN git clone https://github.com/ArseLinuxOS-Development/ArseLinuxOS-ISO.git
ENTRYPOINT ["/bin/bash", "/root/ArseLinuxOS-ISO/build.sh"]
