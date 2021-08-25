/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

/**
 * Popup for loading an existing Wallet.
 * Parameters:
 * - folder: folder path where the Wallet is located
 * - pass: the passphrase for the Wallet
 * - walletExists: bool for when a Wallet exists in the given path
 * - loadBtn: alias for the "Load Wallet" button
 */
AVMEPopup {
  id: loadWalletPopup
  property alias folder: loadFolderInput.text
  property alias pass: loadPassInput.text
  property bool walletExists
  property alias loadBtn: btnLoad

  onAboutToShow: {
    loadFolderInput.text = qmlSystem.getDefaultWalletPath()
    walletExists = qmlSystem.checkFolderForWallet(loadFolderInput.text)
    loadPassInput.focus = true
  }

  function clean() {
    loadFolderInput.text = ""
    loadPassInput.text = ""
  }

  Column {
    id: loadItems
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

    // Enter/Numpad enter key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnLoad.enabled) { loadWallet() }
      }
    }

    Text {
      id: info
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Enter the following details to load a Wallet."
    }

    // Load Wallet folder
    Row {
      id: loadFolderRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: loadFolderInput
        width: (loadItems.width * 0.9) - (loadFolderDialogBtn.width + parent.spacing)
        readOnly: true
        label: "Wallet folder"
        placeholder: "Your Wallet's top folder"
      }
      AVMEButton {
        id: loadFolderDialogBtn
        width: (loadItems.width * 0.1)
        height: loadFolderInput.height
        text: ""
        onClicked: loadFolderDialog.visible = true
        Image {
          anchors.fill: parent
          anchors.margins: 10
          source: "qrc:/img/icons/folder.png"
          antialiasing: true
          smooth: true
          fillMode: Image.PreserveAspectFit
        }
      }
      FolderDialog {
        id: loadFolderDialog
        title: "Choose your Wallet folder"
        onAccepted: {
          loadFolderInput.text = qmlSystem.cleanPath(loadFolderDialog.folder)
          walletExists = qmlSystem.checkFolderForWallet(loadFolderInput.text)
        }
      }
    }

    // Passphrase
    AVMEInput {
      id: loadPassInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: (loadItems.width * 0.9)
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    AVMEButton {
      id: btnLoad
      width: (loadItems.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (loadFolderInput.text != "" && loadPassInput.text != "" && walletExists)
      text: (walletExists) ? "Load Wallet" : "No Wallet found"
    }

    AVMEButton {
      id: btnClose
      width: (loadItems.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Back"
      onClicked: {
        loadWalletPopup.clean()
        loadWalletPopup.close()
      }
    }
  }
}
