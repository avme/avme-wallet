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
      text: "Enter the following details to create a new Wallet."
    }

    // Wallet folder
    Row {
      id: folderRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: folderText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Wallet path:"
      }
      TextField {
        id: folderInput
        width: items.width / 2
        readOnly: true
        placeholderText: "Folder path for your wallet file"
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
        title: "Choose a folder for your wallet file"
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

      Text {
        id: fileText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Wallet file name:"
      }
      TextField {
        id: fileInput
        width: items.width / 4
        selectByMouse: true
        placeholderText: "Name of your wallet file"
      }
    }

    // Secrets folder
    Row {
      id: secretsRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: secretsText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Secrets path:"
      }
      TextField {
        id: secretsInput
        width: items.width / 2
        readOnly: true
        placeholderText: "Folder path for your wallet secrets"
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
        title: "Choose a folder for your wallet secrets"
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
        placeholderText: "Enter a passphrase for your wallet"
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
            // TODO: show this message on screen with a label
            print ("Error on wallet creation/loading")
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
