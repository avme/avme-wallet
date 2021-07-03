/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

/**
 * Popup for creating a new Wallet.
 * Parameters:
 * - folder: folder path where the new Wallet will be located
 * - pass: the passphrase for the new Wallet
 * - seed: optional BIP39 12-word seed to be used
 * - walletExists: bool for when a Wallet exists in the given path
 * - createBtn: alias for the "Create Wallet" button
 */
AVMEPopup {
  id: createWalletPopup
  property alias folder: createFolderInput.text
  property alias pass: createPassInput.text
  property string seed
  property bool walletExists
  property alias createBtn: btnCreate

  onAboutToShow: {
    createFolderInput.text = QmlSystem.getDefaultWalletPath()
    walletExists = QmlSystem.checkFolderForWallet(createFolderInput.text)
  }

  function clean() {
    seed = ""
    createFolderInput.text = ""
    createPassInput.text = ""
    createPassCheckInput.text = ""
  }

  Column {
    id: createItems
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

    // Enter/Return key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (createBtn.enabled) { createWallet() }
      }
    }

    Text {
      id: info
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Enter the following details to create a Wallet."
    }

    // Create Wallet folder
    Row {
      id: createFolderRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: createFolderInput
        width: (createItems.width * 0.9) - (createFolderDialogBtn.width + parent.spacing)
        readOnly: true
        label: "Wallet folder"
        placeholder: "Your Wallet's top folder"
      }
      AVMEButton {
        id: createFolderDialogBtn
        width: (createItems.width * 0.1)
        height: createFolderInput.height
        text: ""
        onClicked: createFolderDialog.visible = true
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
        id: createFolderDialog
        title: "Choose your Wallet folder"
        onAccepted: {
          createFolderInput.text = QmlSystem.cleanPath(createFolderDialog.folder)
          walletExists = QmlSystem.checkFolderForWallet(createFolderInput.text)
        }
      }
    }

    // Passphrase + view button
    Row {
      id: createPassRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: createPassInput
        width: (createItems.width * 0.9) - (createPassViewBtn.width + parent.spacing)
        echoMode: (createPassViewBtn.view) ? TextInput.Normal : TextInput.Password
        passwordCharacter: "*"
        label: "Passphrase"
        placeholder: "Your Wallet's passphrase"
      }
      AVMEButton {
        id: createPassViewBtn
        property bool view: false
        width: (createItems.width * 0.1)
        height: createPassInput.height
        text: ""
        onClicked: view = !view
        Image {
          anchors.fill: parent
          anchors.margins: 10
          source: (parent.view) ? "qrc:/img/icons/eye-f.png" : "qrc:/img/icons/eye-close-f.png"
          antialiasing: true
          smooth: true
          fillMode: Image.PreserveAspectFit
        }
      }
    }

    // Confirm passphrase + check icon
    Row {
      id: createPassCheckRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: createPassCheckInput
        width: (createItems.width * 0.9) - (createPassCheckIcon.width + parent.spacing)
        echoMode: (createPassViewBtn.view) ? TextInput.Normal : TextInput.Password
        passwordCharacter: "*"
        label: "Confirm passphrase"
        placeholder: "Your Wallet's passphrase"
      }

      Image {
        id: createPassCheckIcon
        width: (createItems.width * 0.1)
        height: createPassCheckInput.height
        antialiasing: true
        smooth: true
        fillMode: Image.PreserveAspectFit
        source: {
          if (createPassInput.text == "" || createPassCheckInput.text == "") {
            source: ""
          } else if (createPassInput.text == createPassCheckInput.text) {
            source: "qrc:/img/ok.png"
          } else {
            source: "qrc:/img/no.png"
          }
        }
      }
    }

    AVMEButton {
      id: btnCreate
      width: (createItems.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (
        createFolderInput.text != "" && createPassInput.text != ""
        && createPassCheckInput.text != "" && !walletExists
        && createPassInput.text == createPassCheckInput.text
      )
      text: {
        if (walletExists) {
          text: "Wallet exists in given folder"
        } else if (createPassInput.text != createPassCheckInput.text) {
          text: "Passphrases don't match"
        } else {
          text: (seed == "") ? "Create Wallet" : "Import Wallet"
        }
      }
    }

    AVMEButton {
      id: btnClose
      width: (createItems.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Back"
      onClicked: {
        createWalletPopup.clean()
        createWalletPopup.close()
      }
    }
  }
}
