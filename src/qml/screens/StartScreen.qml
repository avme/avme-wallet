import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Initial screen (for creating/loading a Wallet)

Item {
  id: startScreen

  Column {
    anchors.fill: parent
    spacing: 30
    topPadding: 50

    // Logo
    Image {
      id: logo
      height: 120
      anchors.horizontalCenter: parent.horizontalCenter
      fillMode: Image.PreserveAspectFit
      source: "qrc:/img/avme_banner.png"
    }

    // Buttons
    AVMEButton {
      id: btnNewWallet
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 4
      height: 60
      text: "Create a new Wallet"
      onClicked: System.setScreen(content, "qml/screens/NewWalletScreen.qml")
    }

    AVMEButton {
      id: btnLoadWallet
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 4
      height: 60
      text: "Load an existing Wallet"
      onClicked: System.setScreen(content, "qml/screens/LoadWalletScreen.qml")
    }

    AVMEButton {
      id: btnImportSeed
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 4
      height: 60
      text: "Import a Wallet Seed (WIP)"
    }
  }
}