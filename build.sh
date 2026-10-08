#!/bin/bash
# Builds the splash in colours taken from your current Omarchy theme.
# Usage: build.sh <output-dir>   (runs as your user, no sudo needed)
set -euo pipefail

here="$(dirname "$(readlink -f "$0")")"
out="${1:?usage: build.sh <output-dir>}"
theme_dir="$HOME/.local/state/omarchy/current/theme"
colors="$theme_dir/colors.toml"
defaults="${OMARCHY_PATH:-/usr/share/omarchy}/default/plymouth"

command -v magick >/dev/null || { echo "ImageMagick (magick) is needed: sudo pacman -S imagemagick" >&2; exit 1; }

# Osaka Jade values are used for anything the theme doesn't define.
declare -A fallback=(
  [background]=111c18 [dark_background]=0c1512 [lighter_background]=23372b
  [accent]=509475 [foreground]=c1c497 [dark_foreground]=81b8a8
  [red]=ff5345 [orange]=a2734b [cyan]=2dd5b7 [bright_green]=63b07a [bright_yellow]=e5c736
)

color() { # first key the theme defines wins
  local k v
  for k in "$@"; do
    v=$(sed -nE "s/^$k[[:space:]]*=[[:space:]]*\"#?([0-9a-fA-F]{6})\".*/\1/p" "$colors" 2>/dev/null | head -1)
    [[ -n $v ]] && { echo "${v,,}"; return; }
  done
  echo "${fallback[$1]:-ffffff}"
}
rgb() { awk -v h="$1" 'function d(x){return index("0123456789abcdef",substr(h,x,1))-1} BEGIN{printf "%.3f, %.3f, %.3f", (d(1)*16+d(2))/255, (d(3)*16+d(4))/255, (d(5)*16+d(6))/255}'; }
part() { rgb "$1" | cut -d, -f"$2" | tr -d ' '; }

bg=$(color background)
panel=$(color dark_background background)
bar=$(color lighter_background selection background)
border=$(color accent blue)
text=$(color foreground)
title=$(color dark_foreground muted foreground)
ok=$(color bright_green green)
wait=$(color bright_yellow yellow)
stop=$(color orange brown red)
info=$(color cyan bright_cyan accent)
red=$(color red)
font=$(omarchy-font-current 2>/dev/null || true); font=${font:-JetBrainsMono Nerd Font}

mkdir -p "$out"
cp "$here"/theme/* "$out"/
# Start from Omarchy's own splash pieces when they're there, so the logo and
# unlock box match the rest of the system, then tint them like Omarchy does.
for f in bullet.png entry.png lock.png logo.png progress_bar.png progress_box.png; do
  [[ -f $defaults/$f ]] && cp "$defaults/$f" "$out/$f"
done
# A theme that ships its own splash logo keeps it as is; otherwise the
# Omarchy logo is drawn in the theme's accent colour.
if [[ -f $theme_dir/plymouth/logo.png && ! -L $theme_dir/plymouth/logo.png ]]; then
  cp "$theme_dir/plymouth/logo.png" "$out/logo.png"
else
  magick "$out/logo.png" -channel RGB +level-colors "#$border","#$border" "$out/logo.png"
fi
for f in bullet.png entry.png lock.png progress_bar.png; do
  magick "$out/$f" -channel RGB +level-colors "#$text","#$text" "$out/$f"
done

# The terminal window: rounded panel, title bar with three dots.
magick -size 1100x330 xc:none \
  -fill "#${panel}eb" -stroke "#$border" -strokewidth 2 -draw "roundrectangle 1,1 1098,328 14,14" \
  -stroke none -fill "#$bar" -draw "roundrectangle 2,2 1097,38 13,13" -draw "rectangle 2,24 1097,38" \
  -fill "#$border" -draw "rectangle 2,38 1097,39" \
  -fill "#$red" -draw "circle 24,20 30,20" -fill "#$wait" -draw "circle 46,20 52,20" -fill "#$ok" -draw "circle 68,20 74,20" \
  "$out/terminal.png"

sed -i \
  -e "s/@BG@/$(rgb "$bg")/g" -e "s/@TITLE@/$(rgb "$title")/g" -e "s/@TEXT@/$(rgb "$text")/g" \
  -e "s/@OK_R@/$(part "$ok" 1)/; s/@OK_G@/$(part "$ok" 2)/; s/@OK_B@/$(part "$ok" 3)/" \
  -e "s/@WAIT_R@/$(part "$wait" 1)/; s/@WAIT_G@/$(part "$wait" 2)/; s/@WAIT_B@/$(part "$wait" 3)/" \
  -e "s/@STOP_R@/$(part "$stop" 1)/; s/@STOP_G@/$(part "$stop" 2)/; s/@STOP_B@/$(part "$stop" 3)/" \
  -e "s/@INFO_R@/$(part "$info" 1)/; s/@INFO_G@/$(part "$info" 2)/; s/@INFO_B@/$(part "$info" 3)/" \
  "$out/omarchy-terminal.script"
sed -i -e "s/@BGHEX@/$bg/" -e "s/@FONT@/$font/g" "$out/omarchy-terminal.plymouth"

echo "Built for theme: $(omarchy-theme-current 2>/dev/null || echo unknown)"
