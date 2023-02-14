FROM archlinux:latest
RUN pacman -Sy
RUN pacman -S --noconfirm git reflector archiso mkinitcpio-archiso
ARG USER
RUN git clone https://github.com/LiamAEdwards/ArseLinuxOS-ISO.git
ENTRYPOINT ["/bin/bash", "/home/$USER/ArseLinuxOS-ISO/build.sh"]
