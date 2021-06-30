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
 * - seed: optional BIP39 12-word seed to be used
 * - walletExists: bool for when a Wallet exists in the given path
 */
AVMEPopup {
  id: createWalletPopup
  sizePct: 0.5
  property string seed
  property bool walletExists
  // TODO: check this
  //Keys.onReturnPressed: btnCreate.createWallet() // Enter key
  //Keys.onEnterPressed: btnCreate.createWallet() // Numpad enter key

  Column {
    id: createItems
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

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
        Component.onCompleted: {
          createFolderInput.text = QmlSystem.getDefaultWalletPath()
          walletExists = QmlSystem.checkFolderForWallet(createFolderInput.text)
        }
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

    // Buttons for Create/Import Wallet
    Row {
      id: btnCreateRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      AVMEButton {
        id: btnClose
        width: (createItems.width * 0.3)
        text: "Back"
        // TODO: clean popup inputs and data here
        onClicked: {
          createWalletPopup.close()
        }
      }

      AVMEButton {
        id: btnCreate
        width: (createItems.width * 0.3)
        enabled: (
          createFolderInput.text != "" && createPassInput.text != ""
          && createPassCheckInput.text != "" && !walletExists
          && createPassInput.text == createPassCheckInput.text
        )
        text: {
          if (walletExists) {
            text: "Wallet exists"
          } else if (!walletExists && seed == "") {
            text: "Create Wallet"
          } else if (!walletExists && seed != "") {
            text: "Import Wallet"
          }
        }
        onClicked: btnCreate.createWallet();
        function createWallet() {
          try {
            if (createPassInput.text != createPassCheckInput.text) {
              throw "Passphrases don't match. Please check your inputs."
            } else if (!walletExists && seed == "") {
              if (!QmlSystem.createWallet(createFolderInput.text, createPassInput.text)) {
                throw "Error on Wallet creation. Please check"
                + "<br>the folder path and/or passphrase."
              }
              console.log("Wallet created successfully, now loading it...")
            } else if (!walletExists && seed != "") {
              if (!QmlSystem.seedIsValid(seed)) {
                throw "Error on Wallet importing. Seed is invalid,"
                + "<br>please check the spelling and/or formatting."
              } else if (!QmlSystem.importWallet(seed, createFolderInput.text, createPassInput.text)) {
                throw "Error on Wallet importing. Please check"
                + "<br>the folder path and/or passphrase.";
              }
              console.log("Wallet imported successfully, now loading it...")
            }
            if (QmlSystem.isWalletLoaded()) {
              QmlSystem.stopAllBalanceThreads()
              QmlSystem.closeWallet()
            }
            if (!QmlSystem.loadWallet(createFolderInput.text, createPassInput.text)) {
              throw "Error on Wallet loading. Please check"
              + "<br>the folder path and/or passphrase.";
            }
            console.log("Wallet loaded successfully")
            newWalletSeedPopup.newWalletPass = createPassInput.text
            newWalletSeedPopup.showSeed()
            newWalletSeedPopup.open()
          } catch (error) {
            walletFailPopup.info = error.toString()
            walletFailPopup.open()
          }
        }
      }
    }
  }
}
