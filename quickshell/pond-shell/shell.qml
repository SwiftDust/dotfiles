// Pond shell overlay entry point.
//
// The packaged Pond shell is loaded unchanged through the UpstreamShell.qml
// symlink. Put additions in Custom.qml (or add more files in this directory
// and instantiate them below). Because this directory contains symlinks to
// Pond's QML files, singletons such as Theme, PanelStyle and NiriMsg are
// available to your own files through the implicit directory import.
import QtQuick
import Quickshell

ShellRoot {
  Loader { source: "UpstreamShell.qml" }

  Variants {
    model: Quickshell.screens
    delegate: Scope {
      required property var modelData
      Custom { screen: modelData }
    }
  }
}
