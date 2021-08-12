/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Screen for showing general settings
Item {
  id: settingsScreen

  AVMEPanel {
    id: settingsPanel
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "General Settings"

    Column {
      id: settingsCol
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 80
        bottomMargin: 40
        leftMargin: 40
        rightMargin: 40
      }
      spacing: 40

      Text {
        id: viewPrivKeyText
        width: settingsCol.width * 0.75
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "View/Export the private key for this Account"

        AVMEButton {
          id: btnViewPrivKey
          width: settingsCol.width * 0.25
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.right
          }
          text: "View Private Key"
          onClicked: {
            viewPrivKeyPopup.account = accountHeader.currentAddress
            viewPrivKeyPopup.open()
          }
        }
      }

      Text {
        id: viewSeedText
        width: settingsCol.width * 0.75
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "View/Export the BIP39 seed for this Wallet"

        AVMEButton {
          id: btnViewSeed
          width: settingsCol.width * 0.25
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.right
          }
          text: "View Wallet Seed"
          onClicked: viewSeedPopup.open()
        }
      }
    }
  }

  // Popups for viewing the Account's private key and seed, respectively
  AVMEPopupViewPrivKey { id: viewPrivKeyPopup }
  AVMEPopupViewSeed { id: viewSeedPopup }
}
