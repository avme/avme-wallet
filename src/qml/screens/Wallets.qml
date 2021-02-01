import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

Item {
  Column {
    id: buttons
    anchors.fill: parent
    spacing: 30
    topPadding: 50

    Row {
      id: logo
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Image {
        id: logo_png
        source: "qrc:/img/avme_logo.png"
      }

      Text {
        id: logo_text
        text: "AVME"
        font.bold: true
        font.pointSize: 72.0
        anchors.verticalCenter: logo_png.verticalCenter
      }
    }

    AVMEButton {
      id: btnLoadDefaultWallet
      height: 60
      width: parent.width / 2
      text: "Load the default Wallet"
      anchors.horizontalCenter: parent.horizontalCenter
    }

    AVMEButton {
      id: btnNewWallet
      height: 60
      width: parent.width / 2
      text: "Create and load a new Wallet"
      anchors.horizontalCenter: parent.horizontalCenter
    }

    AVMEButton {
      id: btnLoadWallet
      height: 60
      width: parent.width / 2
      text: "Load an existing Wallet"
      anchors.horizontalCenter: parent.horizontalCenter
    }

    AVMEButton {
      id: btnImportSeed
      height: 60
      width: parent.width / 2
      text: "Import a Wallet with a Seed"
      anchors.horizontalCenter: parent.horizontalCenter
    }
  }
}
