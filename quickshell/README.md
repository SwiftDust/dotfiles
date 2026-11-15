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

After a `pond-shell` update, refresh the links and restart the shell:

```bash
./pond-shell/sync-upstream.sh
```

One-time setup (already done):

```bash
mkdir -p ~/.config/quickshell
ln -sfn ~/dotfiles/quickshell/pond-shell ~/.config/quickshell/pond-shell
```

Your own files live directly in `pond-shell/` next to the symlinks, so Pond's
QML singletons (`Theme`, `PanelStyle`, `NiriMsg`, ...) are available through
the implicit directory import. Add windows/components in `Custom.qml`, or add
new files and instantiate them from the wrapper.
