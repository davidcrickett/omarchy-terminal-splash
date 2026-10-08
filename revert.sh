#!/bin/bash
# Goes back to the normal Omarchy boot splash.
set -e
sudo plymouth-set-default-theme omarchy
if command -v limine-mkinitcpio >/dev/null; then sudo limine-mkinitcpio; else sudo mkinitcpio -P; fi
echo "Back to the standard Omarchy splash."
