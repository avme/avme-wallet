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

    // TODO: turn logo into an image (for better/easier scaling)
    Row {
      id: logo
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Image {
        id: logoPng
        source: "qrc:/img/avme_logo.png"
      }

      Text {
        id: logoText
        anchors.verticalCenter: logoPng.verticalCenter
        font.bold: true
        font.pointSize: 72.0
        text: "AVME"
      }
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
            // TODO: show this message on screen with a label
            console.log("Error on wallet load. Please check the paths and/or passphrase")
          }
        }
      }
    }
  }
}
