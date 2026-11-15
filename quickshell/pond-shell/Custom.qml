import QtQuick
import Quickshell.Wayland

// Your own Pond shell additions go here.
//
// This file lives in the overlay directory, so Pond's singletons (Theme,
// PanelStyle, NiriMsg, ...) are available without an explicit import.
Item {
    id: root
    required property var screen

    // Example window. Uncomment and adjust:
    //
    // PanelWindow {
    //     screen: root.screen
    //     anchors { top: true; left: true }
    //     margins { top: 8; left: 8 }
    //     implicitWidth: 200
    //     implicitHeight: 40
    //     color: Theme.colors.surface
    //
    //     Text {
    //         anchors.centerIn: parent
    //         text: "Hello from Pond"
    //         color: Theme.colors.text
    //     }
    // }
}
