#!/bin/bash
# Installs the Omarchy Terminal boot splash in your current theme's colours
# and rebuilds the boot image. Run it again after switching themes.
set -euo pipefail
here="$(dirname "$(readlink -f "$0")")"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
"$here/build.sh" "$tmp"
sudo install -d /usr/share/plymouth/themes/omarchy-terminal
sudo install -m 0644 "$tmp"/* /usr/share/plymouth/themes/omarchy-terminal/
sudo plymouth-set-default-theme omarchy-terminal
if command -v limine-mkinitcpio >/dev/null; then sudo limine-mkinitcpio; else sudo mkinitcpio -P; fi
echo "Done. Reboot to see it."
