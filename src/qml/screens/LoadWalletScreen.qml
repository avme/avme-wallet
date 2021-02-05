import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for loading an existing Wallet

Item {
  id: loadWalletScreen

  Column {
    id: items
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

    Text {
      id: info
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Enter the following details to load a Wallet."
    }

    // Wallet file path
    Row {
      id: fileRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: fileText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Wallet file:"
      }
      TextField {
        id: fileInput
        width: items.width / 2
        readOnly: true
        placeholderText: "Your wallet file"
      }
      AVMEButton {
        id: fileDialogBtn
        width: 40
        height: fileInput.height
        text: "..."
        onClicked: fileDialog.visible = true
      }
      FileDialog {
        id: fileDialog
        title: "Choose a wallet file"
        onAccepted: {
          fileInput.text = fileDialog.file
        }
      }
    }

    // Secrets folder path
    Row {
      id: secretsRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: secretsText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Secrets folder:"
      }
      TextField {
        id: secretsInput
        width: items.width / 2
        readOnly: true
        placeholderText: "Your wallet secrets folder"
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
        title: "Choose a secrets folder"
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

      Text {
        id: passText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Passphrase:"
      }
      TextField {
        id: passInput
        width: items.width / 4
        selectByMouse: true
        echoMode: TextInput.Password
        passwordCharacter: "*"
        placeholderText: "Enter your wallet's passphrase"
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
          var walletFile = fileInput.text
          var secretsPath = secretsInput.text
          var walletPass = passInput.text
          if (System.loadWallet(walletFile, secretsPath, walletPass)) {
            console.log("Wallet loaded successfully")
            System.setWalletPass(walletPass)
            System.setScreen(content, "qml/screens/AccountsScreen.qml")
          } else {
            walletFailPopup.open()
          }
        }
      }
    }
  }

  // Info popup for if the Wallet loading fails
  AVMEPopupInfo {
    id: walletFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on Wallet load.<br>Please check the paths and/or passphrase."
  }
}
