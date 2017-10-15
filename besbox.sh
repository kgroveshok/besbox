#!/bin/sh

# preflight checks
# package checks and install

#sudo apt install flite sqlite3 mplayer vlc pavucontrol
#sudo apt-get install pulseaudio pulseaudio-module-bluetooth
#sudo apt-get install bluez blueman xauth alsa-utils bluez-alsa
# apply system config

mkdir ~/.besbox
touch ~/.besbox/config.db

# configure bluetooth speaker

sudo usermod –a –G lp pi
hciconfig hci0 up
# to find and pair
#bluethoothctl -a
# scan on
# info <mac>
# pair <mac>
# trust <mac>

# to connect
#bluethoothctl <<EOF
#connect <mac>
#EOF

# disable onboard sound
# /boot/config.txt
# comment out dtparam=audio=on

pulseaudio --start

sudo bluetoothctl <<EOF
connect FC:58:FA:BE:05:6C 
EOF

# launch menu system

./besbox.pl



