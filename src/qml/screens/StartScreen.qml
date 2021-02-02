import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

Item {
  id: start_screen

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
      id: btnNewWallet
      height: 60
      width: parent.width / 4
      text: "Create a new Wallet"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: {
        System.setScreen(content, "qml/screens/NewWalletScreen.qml")
      }
    }

    AVMEButton {
      id: btnLoadWallet
      height: 60
      width: parent.width / 4
      text: "Load an existing Wallet"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: {
        System.setScreen(content, "qml/screens/LoadWalletScreen.qml")
      }
    }

    AVMEButton {
      id: btnImportSeed
      height: 60
      width: parent.width / 4
      text: "Import a Wallet Seed (WIP)"
      anchors.horizontalCenter: parent.horizontalCenter
    }
  }
}
