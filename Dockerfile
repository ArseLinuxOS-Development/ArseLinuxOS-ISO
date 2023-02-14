FROM archlinux:latest
RUN pacman -Sy
RUN pacman -S --noconfirm git reflector archiso mkinitcpio-archiso
ARG USER
RUN git clone git@github.com:ArseLinuxOS-Development/ArseLinuxOS-ISO.git
ENTRYPOINT ["/bin/bash", "/root/ArseLinuxOS-ISO/build.sh"]
