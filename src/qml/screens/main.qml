import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import "qrc:/qml/components"

// The main window

ApplicationWindow {
  id: window
  property alias menu: sideMenu

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
    color: "#252935"
  }

  AVMESideMenu {
    id: sideMenu
    width: 80
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
    }
  }

  // Dynamic screen loader (used in setScreen(id, screenpath))
  Loader {
    id: content
    anchors {
      left: sideMenu.left
      right: parent.right
      top: parent.top
      bottom: parent.bottom
    }
    source: "qrc:/qml/screens/StartScreen.qml"
  }
}
