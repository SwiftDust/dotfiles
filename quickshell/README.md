# Quickshell overlay

`pond-shell/` is a Quickshell config that shadows the packaged
`/etc/xdg/quickshell/pond-shell` (which points at
`/usr/share/pond-interface/shell`).

- `pond-shell/shell.qml` is our wrapper. It loads the upstream shell through
  `pond-shell/UpstreamShell.qml` and appends `Custom.qml`.
- Every other top-level entry in `pond-shell/` is a symlink into
  `/usr/share/pond-interface/shell`, so `pond-shell` package updates flow
  through automatically. Do not edit the symlinked files.
- `wallpaper` (next to this README) links to
  `/usr/share/pond-interface/wallpaper` because Pond resolves
  `Quickshell.shellDir + "/../wallpaper/control.py"`.

## Automatic refresh on package updates

A systemd user path unit watches the packaged shell and reruns the sync script
whenever files are added, removed or rewritten:

- `systemd/pond-shell-sync.path` watches `/usr/share/pond-interface/shell`
- `systemd/pond-shell-sync.service` runs `pond-shell/sync-upstream.sh`

It is enabled already. Check or re-enable it with:

```bash
systemctl --user status pond-shell-sync.path
systemctl --user enable --now pond-shell-sync.path
```

The unit only runs while you are logged in. If `pond-shell` was updated while
you were logged out, run the script manually (or start the service) on the next
login:

```bash
systemctl --user start pond-shell-sync.service
```

Alternatively, a pacman hook is included as `pond-shell/pond-shell-sync.hook`.
Installing it makes pacman run the sync directly after every `pond-shell`
transaction, even when no user session is active:

```bash
sudo install -Dm644 ~/dotfiles/quickshell/pond-shell/pond-shell-sync.hook \
  /etc/pacman.d/hooks/pond-shell-sync.hook
```

The hook runs the script as `mart` with `runuser`, so files stay user-owned.

## Restarting after an update

Symlink changes need a shell restart before Quickshell picks them up:

```bash
qs kill -c pond-shell
qs -c pond-shell -d
```

## One-time setup (already done)

```bash
mkdir -p ~/.config/quickshell
ln -sfn ~/dotfiles/quickshell/pond-shell ~/.config/quickshell/pond-shell

mkdir -p ~/.config/systemd/user
ln -sfn ~/dotfiles/quickshell/systemd/pond-shell-sync.path \
  ~/.config/systemd/user/pond-shell-sync.path
ln -sfn ~/dotfiles/quickshell/systemd/pond-shell-sync.service \
  ~/.config/systemd/user/pond-shell-sync.service
systemctl --user daemon-reload
systemctl --user enable --now pond-shell-sync.path
```

Your own files live directly in `pond-shell/` next to the symlinks, so Pond's
QML singletons (`Theme`, `PanelStyle`, `NiriMsg`, ...) are available through
the implicit directory import. Add windows/components in `Custom.qml`, or add
new files and instantiate them from the wrapper.
