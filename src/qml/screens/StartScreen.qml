import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Initial screen (for creating/loading a Wallet)

Item {
  id: startScreen
  property bool walletExists

  Column {
    id: items
    anchors.fill: parent
    spacing: 40
    topPadding: 40

    // Logo
    Image {
      id: logo
      height: 120
      anchors.horizontalCenter: parent.horizontalCenter
      fillMode: Image.PreserveAspectFit
      source: "qrc:/img/avme_banner.png"
    }

    // Welcome text
    Text {
      id: welcomeText
      color: "#FFFFFF"
      font.pointSize: 18.0
      font.bold: true
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      text: "Welcome to the AVME Wallet"
    }

    // Wallet folder
    Row {
      id: folderRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: folderInput
        width: (items.width / 2) - (folderDialogBtn.width + parent.spacing)
        readOnly: true
        label: "Wallet folder"
        placeholder: "Your Wallet's top folder"
      }
      AVMEButton {
        id: folderDialogBtn
        width: 40
        height: folderInput.height
        text: "..."
        onClicked: folderDialog.visible = true
      }
      FolderDialog {
        id: folderDialog
        title: "Choose your Wallet folder"
        onAccepted: {
          folderInput.text = System.cleanPath(folderDialog.folder)
          walletExists = System.checkFolderForWallet(folderInput.text)
          if (walletExists) { seedInput.text = "" }
        }
      }
    }

    // Passphrase
    AVMEInput {
      id: passInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: items.width / 2
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    // Optional seed
    AVMEInput {
      id: seedInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: items.width / 2
      visible: (folderInput.text != "" && !walletExists)
      enabled: visible
      label: "(Optional) Seed"
      placeholder: "Restoring an existing Wallet? Enter your 12-word seed here"
    }

    // Button
    AVMEButton {
      id: btn
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 4
      enabled: (folderInput.text != "" && passInput.text != "")
      height: 60
      text: {
        if (walletExists) {
          text: "Open Wallet"
        } else if (!walletExists && seedInput.text == "") {
          text: "Create Wallet"
        } else if (!walletExists && seedInput.text != "") {
          text: "Import Wallet"
        }
      }
      onClicked: {
        try {
          if (!walletExists && seedInput.text == "") {
            if (!System.createWallet(folderInput.text, passInput.text)) {
              throw "Error on Wallet creation. Please check"
              + "<br>the folder path and/or passphrase.";
            }
            console.log("Wallet created successfully, now loading it...")
          } else if (!walletExists && seedInput.text != "") {
            if (!System.seedIsValid(seedInput.text)) {
              throw "Error on Wallet importing. Seed is invalid,"
              + "<br>please check the spelling and/or formatting."
            } else if (!System.importWallet(seedInput.text, folderInput.text, passInput.text)) {
              throw "Error on Wallet importing. Please check"
              + "<br>the folder path and/or passphrase.";
            }
            console.log("Wallet imported successfully, now loading it...")
          }
          if (!System.loadWallet(folderInput.text, passInput.text)) {
            throw "Error on Wallet loading. Please check"
            + "<br>the folder path and/or passphrase.";
          }
          console.log("Wallet loaded successfully")
          System.setFirstLoad(true)
          System.setScreen(content, "qml/screens/newOverviewPage.qml")
        } catch (error) {
          walletFailPopup.info = error
          walletFailPopup.open()
        }
      }
    }
  }

  // Info popup for if the Wallet creation/loading/importing fails
  AVMEPopupInfo {
    id: walletFailPopup
    icon: "qrc:/img/warn.png"
  }
}
