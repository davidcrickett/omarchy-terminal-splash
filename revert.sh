#!/bin/bash
# Goes back to the normal Omarchy boot splash.
set -e
# Also stop auto-update, so a theme switch doesn't bring the splash back.
rm -f "$HOME/.config/omarchy/hooks/theme-set.d/terminal-splash"
sudo plymouth-set-default-theme omarchy
if command -v limine-mkinitcpio >/dev/null; then sudo limine-mkinitcpio; else sudo mkinitcpio -P; fi
echo "Back to the standard Omarchy splash."
