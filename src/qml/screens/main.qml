import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import "qrc:/qml/components"

ApplicationWindow {
  id: window
  title: qsTr("AVME Wallet")
  width: 1280
  height: 720
  minimumWidth: 1280
  minimumHeight: 720
  visible: true

  Rectangle {
    id: bg
    z: 1
    anchors.fill: parent
    gradient: Gradient {
      GradientStop { position: 0; color: "#782D8B" }
      GradientStop { position: 1; color: "#AB5FBE" }
    }
  }

  Loader {
    id: content
    z: 3
    width: parent.width
    source: "qrc:/qml/screens/StartScreen.qml"
    anchors.fill: parent
  }
}

