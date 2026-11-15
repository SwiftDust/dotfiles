# dotfiles

Configuration for a [Pond](https://butterfly.so) desktop (Niri + Quickshell),
kept in one repository and symlinked into `~/.config`.

## Contents

| Repository path | Linked to | Purpose |
| --- | --- | --- |
| `niri/` | `~/.config/niri` | Niri configuration, including Pond's shell integration and personal settings |
| `quickshell/pond-shell/` | `~/.config/quickshell/pond-shell` | Quickshell overlay around the packaged Pond shell |
| `quickshell/systemd/` | `~/.config/systemd/user/` | Systemd user path unit that refreshes the overlay after `pond-shell` updates |

`niri/shell` is not tracked: it is a package-owned directory from
`/usr/share/pond-interface/config/niri/shell` and is recreated by `install.sh`.

See [`quickshell/README.md`](quickshell/README.md) for details about the
Quickshell overlay.

## Requirements

- Arch Linux with Pond installed (`pond-shell`, `pond-interface`)
- `niri`
- `quickshell`
- `git`

This repository contains configuration only; it does not install packages.

## Installation

Clone the repository and run the installer as your normal user:

```bash
git clone https://github.com/SwiftDust/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is idempotent and safe to re-run. It:

1. Creates `~/dotfiles/niri/shell` pointing at Pond's packaged Niri integration.
2. Links `niri/` to `~/.config/niri`.
3. Links `quickshell/pond-shell/` to `~/.config/quickshell/pond-shell`.
4. Refreshes the symlinks inside the overlay that point into the packaged Pond
   shell (`UpstreamShell.qml`, `Theme.qml`, `settings/`, etc.).
5. Links and enables `pond-shell-sync.path`, which watches the packaged shell
   and reruns the refresh after `pond-shell` updates.

If any destination already exists as a real file or directory, it is moved to
`<path>.bak.<timestamp>` instead of being deleted.

The installer assumes the standard `~/.config` location. To skip the systemd
step, run `./install.sh --no-systemd`.

The repository can live anywhere; the script resolves its own location.

## First start

Log out and back in, or restart Niri, so the new configuration is loaded.

To restart only Quickshell:

```bash
qs kill -c pond-shell
qs -c pond-shell -d
```

## Updating

```bash
cd ~/dotfiles
git pull
./install.sh
```

Re-running the installer is only required when links change (for example, when
a new configuration directory or systemd unit is added). Ordinary edits to
tracked files are picked up through the existing symlinks.

## How the Quickshell overlay works

Pond ships its shell in `/usr/share/pond-interface/shell` (exposed through
`/etc/xdg/quickshell/pond-shell`). This repository puts a user config at
`~/.config/quickshell/pond-shell`, which shadows the system config.

- `quickshell/pond-shell/shell.qml` is the wrapper.
- `quickshell/pond-shell/UpstreamShell.qml` points at Pond's real `shell.qml`.
- Every other top-level entry in the overlay points into the package, so
  upstream file contents update automatically.
- `Custom.qml` is where personal widgets/windows go.

Because the overlay directory contains the upstream QML files, Pond's
singletons (`Theme`, `PanelStyle`, `NiriMsg`, ...) are available to custom
files through the implicit directory import.

When `pond-shell` adds or removes top-level files, the symlinks need refreshing.
The systemd path unit does this automatically while you are logged in; see
[`quickshell/README.md`](quickshell/README.md) for the manual commands and
caveats.

## Optional: pacman hook

The systemd unit only runs during a user session. For updates that happen while
you are logged out, you can additionally install the included pacman hook:

```bash
sudo install -Dm644 ~/dotfiles/quickshell/pond-shell/pond-shell-sync.hook \
  /etc/pacman.d/hooks/pond-shell-sync.hook
```

The hook runs the sync script as user `mart`. If your username is different,
edit the `Exec` line in
`quickshell/pond-shell/pond-shell-sync.hook` before installing it.

## Rollback

Remove the symlinks and restore any backups created by the installer:

```bash
rm ~/.config/niri
rm ~/.config/quickshell/pond-shell
rm ~/.config/systemd/user/pond-shell-sync.path
rm ~/.config/systemd/user/pond-shell-sync.service
systemctl --user disable --now pond-shell-sync.path

# If the installer moved an old config aside:
mv ~/.config/niri.bak.YOUR-TIMESTAMP ~/.config/niri
```

Then log out and back in.
