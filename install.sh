#!/usr/bin/env bash
# Link this repository into the user's configuration directories.
#
# Safe to re-run: existing links are refreshed, and real files/directories that
# would be replaced are moved aside with a .bak.<timestamp> suffix.
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
run_systemd=1
timestamp="$(date +%Y%m%d-%H%M%S)"

usage() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS]

Link the dotfiles in this repository into ~/.config.

Options:
  --no-systemd   Do not enable the systemd user path unit
  -h, --help     Show this help
EOF
}

info() { printf '  %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

for arg in "$@"; do
  case "$arg" in
    --no-systemd) run_systemd=0 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; die "unknown option: $arg" ;;
  esac
done

[[ -d "$repo_dir/niri" ]] || die "niri/ not found next to this script"
[[ -d "$repo_dir/quickshell/pond-shell" ]] || die "quickshell/pond-shell/ not found next to this script"

# Replace a path with a symlink. Never delete real user data silently.
link_path() {
  local src="$1" dest="$2"

  [[ -e "$src" ]] || die "source does not exist: $src"
  mkdir -p -- "$(dirname -- "$dest")"

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink -- "$dest")" == "$src" ]]; then
      info "already linked: $dest"
      return 0
    fi
    rm -- "$dest"
  elif [[ -e "$dest" ]]; then
    local backup="${dest}.bak.${timestamp}"
    mv -- "$dest" "$backup"
    info "backed up: $dest -> $backup"
  fi

  ln -s -- "$src" "$dest"
  info "linked: $dest -> $src"
}

printf 'Linking Niri and Quickshell configuration...\n'

# niri/config.kdl includes ./shell/config.kdl. That directory is owned by the
# Pond package and is intentionally not tracked in this repository.
pond_niri_shell="/usr/share/pond-interface/config/niri/shell"
if [[ -d "$pond_niri_shell" ]]; then
  link_path "$pond_niri_shell" "$repo_dir/niri/shell"
else
  warn "Pond's niri integration was not found at $pond_niri_shell."
  warn "Install pond-shell, or Niri will fail to load this configuration."
fi

links=(
  "$repo_dir/niri|$config_home/niri"
  "$repo_dir/quickshell/pond-shell|$config_home/quickshell/pond-shell"
  "$repo_dir/quickshell/systemd/pond-shell-sync.path|$config_home/systemd/user/pond-shell-sync.path"
  "$repo_dir/quickshell/systemd/pond-shell-sync.service|$config_home/systemd/user/pond-shell-sync.service"
)

for entry in "${links[@]}"; do
  link_path "${entry%%|*}" "${entry#*|}"
done

if [[ "$config_home" != "$HOME/.config" ]]; then
  warn "XDG_CONFIG_HOME is set to $config_home."
  warn "The systemd unit assumes \$HOME/.config; adjust it if needed."
fi

printf '\nRefreshing symlinks into the packaged Pond shell...\n'
if [[ -d /usr/share/pond-interface/shell ]]; then
  "$repo_dir/quickshell/pond-shell/sync-upstream.sh"
else
  warn "/usr/share/pond-interface/shell was not found; skipping."
  warn "Install pond-shell, then run:"
  warn "  $repo_dir/quickshell/pond-shell/sync-upstream.sh"
fi

if (( run_systemd )); then
  printf '\nEnabling the Pond update watcher...\n'
  if command -v systemctl >/dev/null 2>&1 && systemctl --user show-environment >/dev/null 2>&1; then
    systemctl --user daemon-reload
    systemctl --user enable --now pond-shell-sync.path
    info "enabled pond-shell-sync.path"
  else
    warn "systemd user manager is not available."
    warn "After logging in, run:"
    warn "  systemctl --user daemon-reload"
    warn "  systemctl --user enable --now pond-shell-sync.path"
  fi
fi

cat <<'EOF'

Done.

Log out and back in (or restart Niri) so the new Niri and Quickshell
configuration is loaded.

To restart only Quickshell:
  qs kill -c pond-shell
  qs -c pond-shell -d
EOF
