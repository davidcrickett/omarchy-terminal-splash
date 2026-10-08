#!/bin/bash
# Preview the Omarchy Terminal splash in a window, without touching the boot image.
here="$(dirname "$(readlink -f "$0")")"
src=$(mktemp -d); trap 'rm -rf "$src"' EXIT
"$here/build.sh" "$src"
sudo install -d /usr/share/plymouth/themes/omarchy-terminal
sudo install -m 0644 "$src"/* /usr/share/plymouth/themes/omarchy-terminal/
old=$(plymouth-set-default-theme)
sudo plymouth-set-default-theme omarchy-terminal
sudo --preserve-env=DISPLAY,XAUTHORITY plymouthd --no-daemon --debug-file=/tmp/plymouth-preview.log &
sleep 2
sudo plymouth --show-splash
sleep 2
for u in systemd-journald.service systemd-udevd.service NetworkManager.service bluetooth.service cups.service; do sudo plymouth update --status="$u"; sleep 0.7; done
timeout 15 sudo plymouth ask-for-password --prompt="Test password (just press Enter)" >/dev/null
for u in systemd-logind.service power-profiles-daemon.service sddm.service; do sudo plymouth update --status="$u"; sleep 0.7; done
sleep 3
sudo plymouth quit
sudo plymouth-set-default-theme "$old"
echo "Preview finished (boot unchanged)."
