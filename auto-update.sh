#!/bin/bash
# Opt-in: keep the boot splash in step with your Omarchy theme.
#   ./auto-update.sh        turn it on
#   ./auto-update.sh --off  turn it off
# When on, switching themes opens a small Omarchy terminal that runs install.sh
# from this folder. It asks for your sudo password there, like running it by hand.
# Nothing is stored and nothing runs without that visible prompt.
set -euo pipefail
here="$(dirname "$(readlink -f "$0")")"
hook="$HOME/.config/omarchy/hooks/theme-set.d/terminal-splash"

if [[ ${1:-} == --off ]]; then
  rm -f "$hook"
  echo "Auto-update is off. The splash stays as it is until you run ./install.sh."
  exit 0
fi

mkdir -p "$(dirname "$hook")"
cat >"$hook" <<HOOK
#!/bin/bash
# Added by omarchy-terminal-splash/auto-update.sh. Rebuilds the boot splash in
# the new theme's colours. Remove with: $here/auto-update.sh --off
[[ -x "$here/install.sh" ]] || exit 0
(omarchy-launch-floating-terminal-with-presentation "echo 'Updating your boot splash to match the new theme...'; '$here/install.sh'" >/dev/null 2>&1 &)
HOOK
chmod +x "$hook"
echo "Auto-update is on. Next time you switch themes, a terminal will pop up and ask for your password to update the splash."
echo "Keep this folder where it is ($here), since the hook runs install.sh from here."
