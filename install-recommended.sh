#!/bin/bash

# This is a simple script to intall all of the additional terminal cli utilities
# to make additional checks. This will allow checking stuff like nvme temps and
# the RP1 southbridge temp.

# To run this script you need to use sudo.
# you can just put the file in your downloads folder
# and run './Downloads/install-recommended.sh'
# Note: set the script to allow anyone to execute before running it

sudo apt install lm-sensors
sudo apt install nvme-cli

sudo apt install build-essential git meson
git clone https://github.com/hotnuma/sysload.git
cd sysload
./install.sh

# eof
