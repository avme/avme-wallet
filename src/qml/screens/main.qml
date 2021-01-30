import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import "qrc:/qml/components"

Window {
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

  AVMEMenu {
    id: sideMenu
    z: 2
    width: 200
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
    }
  }

  Loader {
    id: content
    z: 3
    width: parent.width - sideMenu.width
    source: "qrc:/qml/screens/Wallets.qml"
    anchors {
      left: sideMenu.right
      right: parent.right
      top: parent.top
      bottom: parent.bottom
    }
  }
}
