import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

Item {
  id: new_wallet_screen

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
      text: "Enter the following details to create a new Wallet."
    }

    Row {
      id: wallet_folder_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: wallet_folder_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Wallet path:"
      }
      TextField {
        id: wallet_folder_input
        width: items.width / 2
        readOnly: true
        placeholderText: "Choose a wallet folder"
      }
      AVMEButton {
        id: wallet_folder_dialog_btn
        text: "..."
        width: 40
        height: wallet_folder_input.height
        onClicked: wallet_folder_dialog.visible = true
      }
      FolderDialog {
        id: wallet_folder_dialog
        title: "Choose a wallet folder"
        onAccepted: {
          wallet_folder_input.text = wallet_folder_dialog.folder
        }
      }
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
        text: "Wallet file name:"
      }
      TextField {
        id: wallet_file_input
        width: items.width / 4
        selectByMouse: true
        placeholderText: "Give a name to your wallet file"
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
        placeholderText: "Enter a passphrase for your wallet"
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
          var walletFile = wallet_folder_input.text + "/" + wallet_file_input.text
          var secretsPath = wallet_secrets_input.text
          var walletPass = passphrase_input.text
          try {
            System.createNewWallet(walletFile, secretsPath, walletPass)
            console.log("Wallet created successfully, now loading it...")
            System.loadWallet(walletFile, secretsPath, walletPass)
            console.log("Wallet loaded successfully")
            System.setScreen(content, "qml/screens/AccountsScreen.qml")
          } catch (error) {
            // TODO: show this message on screen with a label
            print ("Error on wallet creation/loading.")
            for (var i = 0; i < error.qmlErrors.length; i++) {
              print("lineNumber: " + error.qmlErrors[i].lineNumber)
              print("columnNumber: " + error.qmlErrors[i].columnNumber)
              print("fileName: " + error.qmlErrors[i].fileName)
              print("message: " + error.qmlErrors[i].message)
            }
          }
        }
      }
    }
  }
}
