import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Rabbit: one-click "always on" mode for the Omarchy bar.
// It keeps going and going. Bright = suspend, idle, and lid close are blocked.
// Dim = normal power behavior.
BarWidget {
  id: root
  moduleName: "io.github.tyrichards.rabbit"

  readonly property string script: String(Qt.resolvedUrl("bin/omarchy-rabbit")).replace(/^file:\/\//, "")
  readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy/rabbit"

  // Height of the drawn rabbit, ears to chin. The bar is 26px tall.
  readonly property real iconHeight: setting("iconHeight", 22)

  property bool enabled: false

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function toggle() {
    if (toggleProc.running) return
    toggleProc.running = true
  }

  function applyStatus(line) {
    try {
      var data = JSON.parse(line)
      root.enabled = data.enabled === true
    } catch (error) {
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  IpcHandler {
    target: "io.github.tyrichards.rabbit"

    function toggle(): void { root.broadcast("toggle") }
    function refresh(): void { root.broadcast("refresh") }
    function status(): string { return root.enabled ? "on" : "off" }
  }

  Process {
    id: statusProc
    command: ["bash", "-c", root.script + " status"]
    stdout: SplitParser { onRead: function(line) { root.applyStatus(line) } }
  }

  Process {
    id: toggleProc
    command: ["bash", "-c", root.script + " toggle"]
    stdout: SplitParser { onRead: function(line) { root.applyStatus(line) } }
    onExited: function() { root.broadcast("refresh") }
  }

  // Instant updates when the CLI is used outside the bar (keybinding, terminal).
  FileView {
    path: root.stateDir
    watchChanges: true
    printErrors: false
    onFileChanged: root.refresh()
  }

  Timer {
    interval: 10000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    active: root.enabled
    opacity: root.enabled ? 1 : 0.45
    tooltipText: root.enabled ? "Always on: lid close, suspend, and idle blocked" : "Normal power: click to keep going and going"
    onPressed: function(b) {
      if (b === Qt.RightButton) {
        if (root.bar) root.bar.run("xdg-terminal-exec -e bash -c 'systemd-inhibit --list; read -n1'")
        return
      }
      root.toggle()
    }

    Behavior on opacity { NumberAnimation { duration: 160 } }

    // A rabbit head drawn from rounded rectangles, so it recolors with the
    // theme and scales cleanly to any bar size.
    iconComponent: Component {
      Item {
        Item {
          id: rabbit
          anchors.centerIn: parent
          readonly property real unit: root.iconHeight / 22
          property color ink: root.enabled ? button.activeColor : button.foreground
          readonly property color paper: root.bar ? root.bar.background : Color.background
          width: 20 * unit
          height: 22 * unit

          Behavior on ink { ColorAnimation { duration: 160 } }

          // Ears
          Rectangle {
            x: 4 * rabbit.unit; y: 0
            width: 5.2 * rabbit.unit; height: 13.5 * rabbit.unit
            radius: width / 2
            color: rabbit.ink
            transformOrigin: Item.Bottom
            rotation: -16
          }
          Rectangle {
            x: 10.8 * rabbit.unit; y: 0
            width: 5.2 * rabbit.unit; height: 13.5 * rabbit.unit
            radius: width / 2
            color: rabbit.ink
            transformOrigin: Item.Bottom
            rotation: 16
          }

          // Head
          Rectangle {
            x: 3 * rabbit.unit; y: 9.5 * rabbit.unit
            width: 14 * rabbit.unit; height: 12.5 * rabbit.unit
            radius: 6.5 * rabbit.unit
            color: rabbit.ink
          }

          // Eyes
          Rectangle {
            x: 6.6 * rabbit.unit; y: 14 * rabbit.unit
            width: 2.2 * rabbit.unit; height: width; radius: width / 2
            color: rabbit.paper
          }
          Rectangle {
            x: 11.2 * rabbit.unit; y: 14 * rabbit.unit
            width: 2.2 * rabbit.unit; height: width; radius: width / 2
            color: rabbit.paper
          }

          // Nose
          Rectangle {
            x: 9.1 * rabbit.unit; y: 17.4 * rabbit.unit
            width: 1.8 * rabbit.unit; height: 1.4 * rabbit.unit; radius: height / 2
            color: rabbit.paper
          }
        }
      }
    }
  }
}
