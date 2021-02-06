import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for creating a new Wallet

Item {
  id: newWalletScreen

  Column {
    id: items
    anchors.fill: parent
    spacing: 40
    topPadding: 50

    // Logo
    Image {
      id: logo
      height: 120
      anchors.horizontalCenter: parent.horizontalCenter
      fillMode: Image.PreserveAspectFit
      source: "qrc:/img/avme_banner.png"
    }

    Text {
      id: info
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Enter the following details to create a new Wallet."
    }

    // Wallet folder
    Row {
      id: folderRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: folderInput
        width: items.width / 2
        readOnly: true
        label: "Wallet path"
        placeholder: "Path to your Wallet file"
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
        title: "Choose a folder for your Wallet file"
        onAccepted: {
          folderInput.text = folderDialog.folder
        }
      }
    }

    // Wallet file name
    Row {
      id: fileRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: fileInput
        width: items.width / 4
        label: "Wallet file name"
        placeholder: "Name for your Wallet file"
      }
    }

    // Secrets folder
    Row {
      id: secretsRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: secretsInput
        width: items.width / 2
        readOnly: true
        label: "Secrets path"
        placeholder: "Path to your Wallet secrets"
      }
      AVMEButton {
        id: secretsDialogBtn
        width: 40
        height: secretsInput.height
        text: "..."
        onClicked: secretsDialog.visible = true
      }
      FolderDialog {
        id: secretsDialog
        title: "Choose a folder for your Wallet secrets"
        onAccepted: {
          secretsInput.text = secretsDialog.folder
        }
      }
    }

    // Passphrase
    Row {
      id: passRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: passInput
        width: items.width / 4
        echoMode: TextInput.Password
        passwordCharacter: "*"
        label: "Passphrase"
        placeholder: "Passphrase for your Wallet"
      }
    }

    // Buttons
    Row {
      id: btnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnBack
        width: items.width / 8
        height: 60
        text: "Back"
        onClicked: System.setScreen(content, "qml/screens/StartScreen.qml")
      }

      AVMEButton {
        id: btnDone
        width: items.width / 8
        height: 60
        text: "Done"
        onClicked: {
          var walletFile = folderInput.text + "/" + fileInput.text
          var secretsPath = secretsInput.text
          var walletPass = passInput.text
          try {
            System.createNewWallet(walletFile, secretsPath, walletPass)
            console.log("Wallet created successfully, now loading it...")
            System.loadWallet(walletFile, secretsPath, walletPass)
            console.log("Wallet loaded successfully")
            System.setWalletPass(walletPass)
            System.setScreen(content, "qml/screens/AccountsScreen.qml")
          } catch (error) {
            walletFailPopup.open()
          }
        }
      }
    }
  }

  // Info popup for if the Wallet creation fails
  AVMEPopupInfo {
    id: walletFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on Wallet creation/loading.<br>Please check the paths and/or passphrase."
  }
}
