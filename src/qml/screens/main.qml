import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import "qrc:/qml/components"

// The main window

ApplicationWindow {
  id: window
  title: "AVME Wallet"
  width: 1280
  height: 720
  minimumWidth: width
  minimumHeight: height
  maximumWidth: width
  maximumHeight: height
  visible: true

  // Background
  Rectangle {
    id: bg
    anchors.fill: parent
    gradient: Gradient {
      GradientStop { position: 0; color: "#782D8B" }
      GradientStop { position: 1; color: "#AB5FBE" }
    }
  }

  // Dynamic screen loader (used in setScreen(id, screenpath))
  Loader {
    id: content
    anchors.fill: parent
    width: parent.width
    source: "qrc:/qml/screens/StartScreen.qml"
  }
}
