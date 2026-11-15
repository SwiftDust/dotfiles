#!/usr/bin/env bash
# Refresh the symlinks that point into the packaged Pond shell.
# Run this after a pond-shell package update, then restart the shell.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
upstream="/usr/share/pond-interface/shell"

# Only remove symlinks that point into the upstream shell, never user files.
find "$here" -maxdepth 1 -type l -lname "$upstream/*" -delete

for f in "$upstream"/*; do
  name="$(basename "$f")"
  [[ "$name" == "shell.qml" ]] && continue
  ln -sfn "$f" "$here/$name"
done

# shell.qml is replaced by our wrapper, so keep the real one under a new name.
ln -sfn "$upstream/shell.qml" "$here/UpstreamShell.qml"

# Pond's appearance code resolves Quickshell.shellDir + "/../wallpaper".
# Since this directory lives at <dotfiles>/quickshell/pond-shell, the sibling
# link must live at <dotfiles>/quickshell/wallpaper.
wallpaper_link="$here/../wallpaper"
if [[ -L "$wallpaper_link" || ! -e "$wallpaper_link" ]]; then
  ln -sfn /usr/share/pond-interface/wallpaper "$wallpaper_link"
fi
