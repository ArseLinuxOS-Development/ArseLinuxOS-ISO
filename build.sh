if [[ -f "/.dockerenv" ]]; then
    echo "Running inside docker container"
    mkarchiso -v -w /archiso-tmp -o /root/ArseLinuxOS-ISO/ /root/ArseLinuxOS-ISO/.
else
    echo "Running without docker"
    WD=`pwd`
    mkarchiso -v -w $WD/archiso-tmp -o $WD/ArseLinuxOS-ISO $WD/.
fi


