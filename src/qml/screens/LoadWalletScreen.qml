import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

Item {
  id: load_wallet_screen

  Column {
    id: items
    anchors.fill: parent
    spacing: 30
    topPadding: 50

    Row {
      id: logo
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Image { id: logo_png; source: "qrc:/img/avme_logo.png" }
      Text {
        id: logo_text
        text: "AVME"
        font.bold: true
        font.pointSize: 72.0
        anchors.verticalCenter: logo_png.verticalCenter
      }
    }

    Text {
      id: info
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Enter the following details to load a Wallet."
    }

    Row {
      id: wallet_file_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: wallet_file_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Wallet file:"
      }
      TextField {
        id: wallet_file_input
        width: items.width / 2
        readOnly: true
        placeholderText: "Choose a wallet file"
      }
      AVMEButton {
        id: wallet_file_dialog_btn
        text: "..."
        width: 40
        height: wallet_file_input.height
        onClicked: wallet_file_dialog.visible = true
      }
      FileDialog {
        id: wallet_file_dialog
        title: "Choose a wallet file"
        onAccepted: {
          wallet_file_input.text = wallet_file_dialog.file
        }
      }
    }

    Row {
      id: wallet_secrets_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: wallet_secrets_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Secrets path:"
      }
      TextField {
        id: wallet_secrets_input
        width: items.width / 2
        readOnly: true
        placeholderText: "Choose a secrets folder"
      }
      AVMEButton {
        id: wallet_secrets_dialog_btn
        text: "..."
        width: 40
        height: wallet_secrets_input.height
        onClicked: wallet_secrets_dialog.visible = true
      }
      FolderDialog {
        id: wallet_secrets_dialog
        title: "Choose a secrets folder"
        onAccepted: {
          wallet_secrets_input.text = wallet_secrets_dialog.folder
        }
      }
    }

    Row {
      id: passphrase_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: passphrase_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Passphrase:"
      }
      TextField {
        id: passphrase_input
        width: items.width / 4
        selectByMouse: true
        echoMode: TextInput.Password
        passwordCharacter: "*"
        placeholderText: "Enter your wallet's passphrase"
      }
    }

    Row {
      id: btn_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btn_back
        height: 60
        width: items.width / 8
        text: "Back"
        onClicked: System.setScreen(content, "qml/screens/StartScreen.qml")
      }

      AVMEButton {
        id: btn_done
        height: 60
        width: items.width / 8
        text: "Done"
        onClicked: {
          var walletFile = wallet_file_input.text
          var secretsPath = wallet_secrets_input.text
          var walletPass = passphrase_input.text
          if (System.loadWallet(walletFile, secretsPath, walletPass)) {
            console.log("Wallet loaded successfully")
            System.setWalletPass(walletPass)
            System.setScreen(content, "qml/screens/AccountsScreen.qml")
          } else {
            // TODO: show this message on screen with a label
            console.log("Error on wallet load. Please check the paths and/or passphrase.")
          }
        }
      }
    }
  }
}
