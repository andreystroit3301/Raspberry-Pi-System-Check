#!/bin/bash

# This is a simple script to intall all of the additional terminal cli utilities
# to make additional checks. This will allow checking stuff like nvme temps and
# the RP1 southbridge temp.

sudo apt install lm-sensors
sudo apt install nvme-cli

# eof
