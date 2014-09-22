#!/bin/bash

pacman -Syyu
pacman -S mate xorg-server xorg-xinit xorg-server-utils xterm alsa-utils xf86-video-fbdev xf86-input-synaptics
pacman -S lightdm lightdm-gtk2-greeter
systemctl enable lightdm
echo "exec mate-session" > ~/.xinitrc
