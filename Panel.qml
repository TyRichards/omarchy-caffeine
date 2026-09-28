import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Caffeine: one-click "always on" mode for the Omarchy bar.
// Lit  = suspend, idle, and lid close are blocked; everything keeps running.
// Dim  = normal power behavior.
BarWidget {
  id: root
  moduleName: "io.github.tyrichards.caffeine"

  readonly property string script: String(Qt.resolvedUrl("bin/omarchy-caffeine")).replace(/^file:\/\//, "")
  readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy/caffeine"

  property bool enabled: false

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function toggle() {
    if (toggleProc.running) return
    toggleProc.running = true
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  IpcHandler {
    target: "io.github.tyrichards.caffeine"

    function toggle(): void { root.broadcast("toggle") }
    function refresh(): void { root.broadcast("refresh") }
    function status(): string { return root.enabled ? "on" : "off" }
  }

  Process {
    id: statusProc
    command: ["bash", "-c", root.script + " status"]
    stdout: SplitParser {
      onRead: function(line) {
        try {
          var data = JSON.parse(line)
          root.enabled = data.enabled === true
        } catch (error) {
        }
      }
    }
  }

  Process {
    id: toggleProc
    command: ["bash", "-c", root.script + " toggle"]
    stdout: SplitParser {
      onRead: function(line) {
        try {
          var data = JSON.parse(line)
          root.enabled = data.enabled === true
        } catch (error) {
        }
      }
    }
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
    text: "󱐋"
    active: root.enabled
    opacity: root.enabled ? 1 : 0.45
    tooltipText: root.enabled ? "Always on: lid close, suspend, and idle blocked" : "Normal power: click to stay always on"
    onPressed: function(b) {
      if (b === Qt.RightButton) {
        if (root.bar) root.bar.run("systemd-inhibit --list")
        return
      }
      root.toggle()
    }

    Behavior on opacity { NumberAnimation { duration: 160 } }
  }
}
