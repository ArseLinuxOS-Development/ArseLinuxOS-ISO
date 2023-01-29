FROM archlinux:latest
RUN pacman -Sy
RUN pacman -S --noconfirm git reflector archiso mkinitcpio-archiso
WORKDIR "/root"
RUN git clone https://github.com/LiamAEdwards/ArseLinuxOS-ISO.git
ENTRYPOINT ["/bin/bash","/root/ArseLinuxOS-ISO/build.sh"]
