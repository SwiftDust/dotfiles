import QtQuick
import Quickshell.Wayland
import "." as Shell

// Your own Pond shell additions go here.
//
// This file lives in the overlay directory, so Pond's singletons (Theme,
// PanelStyle, NiriMsg, ...) are available without an explicit import.
Shell.Card {
    id: root
    required property var screen

//     width: Shell.Theme.lerp(Shell.Theme.sidebarCardExpandedWidth,
//         Shell.Theme.sidebarCardCollapsedWidth, layoutProgress)
//     height: Shell.Theme.lerp(expandedTargetHeight, collapsedTargetHeight,
//         Shell.Theme.collapseHeight(collapseProgress))
//     visible: height > 0
//     classicColor: Shell.Theme.sidebarBackground
//     animateClassicColor: true
//
//     HoverHandler {
//       id: hover
//       cursorShape: Qt.PointingHandCursor
//     }
//
//     MouseArea {
//       id: pointer
//       anchors.fill: parent
//       acceptedButtons: Qt.LeftButton
//       cursorShape: Qt.PointingHandCursor
//     }
//
//     Item {
//         Column {
//             Text {
//                 text: "hello test"
//             }
//         }
//     }
// }
}
