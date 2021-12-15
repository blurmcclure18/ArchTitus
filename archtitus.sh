#!/bin/bash

    bash 0-preinstall.sh
    arch-chroot /mnt /root/ArchTitus/1-setup.sh
    source /mnt/root/ArchTitus/install.conf
    arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/ArchTitus/2-user.sh
    arch-chroot /mnt /root/ArchTitus/3-post-setup.sh
    source /mnt/root/ArchTitus/desktopenv.conf
    if [[ $desktopenv -eq 1 ]]
    then
        arch-chroot /mnt /root/ArchTitus/4-gnome-settings.sh
    elif [[ $desktopenv -eq 3 ]]
    then
        arch-chroot /mnt /root/ArchTitus/5-lxqt-settings.sh
       elif [[ $desktopenv -eq 4 ]]
    then
        arch-chroot /mnt /root/ArchTitus/5-lxqt-settings.sh
    else
        echo "Done!"
    fi