FROM archlinux:latest
RUN pacman -Sy
RUN pacman -S --noconfirm git reflector archiso mkinitcpio-archiso
ARG USER
RUN useradd $USER
RUN mkdir /home/$USER
WORKDIR /home/$USER
RUN git clone https://github.com/LiamAEdwards/ArseLinuxOS-ISO.git
RUN sed -i 's/USER/$USER/g' /home/$USER/ArseLinuxOS-ISO/build.sh
ENTRYPOINT ["/bin/bash", "/home/$USER/ArseLinuxOS-ISO/build.sh"]
