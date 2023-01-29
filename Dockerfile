FROM archlinux:latest
RUN pacman -Sy
RUN pacman -S --noconfirm git reflector archiso mkinitcpio-archiso
RUN git clone https://github.com/LiamAEdwards/ArseLinuxOS-ISO.git
