/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for showing general settings
Item {
  id: settingsScreen

  AVMEAccountHeader {
    id: accountHeader
  }

  AVMEPanel {
    id: settingsPanel
    anchors {
      top: accountHeader.bottom
      left: parent.left
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "General Settings"

    Column {
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
      }
      spacing: 40

      Text {
        id: viewPrivKeyText
        width: parent.width * 0.8
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "View/Export the private key for this Account"

        AVMEButton {
          id: btnViewPrivKey
          width: settingsPanel.width * 0.2
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.right
            rightMargin: 20
          }
          text: "View Private Key"
          onClicked: {
            viewPrivKeyPopup.account = QmlSystem.getCurrentAccount()
            viewPrivKeyPopup.open()
          }
        }
      }

      Text {
        id: viewSeedText
        width: parent.width * 0.8
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "View/Export the BIP39 seed for this Wallet"

        AVMEButton {
          id: btnViewSeed
          width: settingsPanel.width * 0.2
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.right
            rightMargin: 20
          }
          text: "View Wallet Seed"
          onClicked: viewSeedPopup.open()
        }
      }
    }
  }

  // Popup for viewing the Account's private key
  AVMEPopupViewPrivKey {
    id: viewPrivKeyPopup
    showBtn.onClicked: {
      if (QmlSystem.checkWalletPass(pass)) {
        viewPrivKeyPopup.showPrivKey()
      } else {
        viewPrivKeyPopup.showErrorMsg()
      }
    }
  }

  // Popup for viewing the Wallet's seed
  AVMEPopupViewSeed {
    id: viewSeedPopup
    showBtn.onClicked: {
      if (QmlSystem.checkWalletPass(pass.text)) {
        viewSeedPopup.showSeed()
      } else {
        viewSeedPopup.showErrorMsg()
      }
    }
  }
}
