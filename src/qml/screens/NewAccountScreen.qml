import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for creating a new Account

Item {
  id: newAccountScreen

  AVMEMenu {
    id: sideMenu
  }

  Column {
    id: items
    anchors {
      left: sideMenu.right
      right: parent.right
      top: parent.top
      bottom: parent.bottom
    }
    spacing: 40
    topPadding: 50

    Text {
      id: info
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Enter the following details to create a new Account."
    }

    // Account name/label
    Row {
      id: nameRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: nameInput
        width: items.width / 2
        label: "Name (optional)"
        placeholder: "Label for your Account"
      }
    }

    // Account passphrase
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
        placeholder: "Passphrase for your Account"
      }
    }

    // Account hint
    Row {
      id: hintRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: hintInput
        width: items.width / 2
        echoMode: TextInput.Password
        passwordCharacter: "*"
        label: "Hint (optional)"
        placeholder: "Hint to help you remember the passphrase"
      }
    }

    // Checkbox for using Wallet passphrase as the Account passphrase
    Row {
      id: passCheckRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      CheckBox {
        id: passCheck
        text: "Use wallet passphrase"
        onClicked: {
          passInput.enabled = !passInput.enabled
          hintInput.enabled = !hintInput.enabled
        }
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
        onClicked: System.setScreen(content, "qml/screens/AccountsScreen.qml")
      }

      AVMEButton {
        id: btnDone
        width: items.width / 8
        height: 60
        text: "Done"
        onClicked: {
          var name = nameInput.text
          var pass = passInput.text
          var hint = hintInput.text
          var usesMasterPass = passCheck.checked
          if (usesMasterPass) {
            pass = System.getWalletPass()
            hint = ""
          }
          try {
            System.createNewAccount(name, pass, hint, passCheck)
            console.log("Account created successfully")
            System.setScreen(content, "qml/screens/AccountsScreen.qml")
          } catch (error) {
            accountFailPopup.open()
          }
        }
      }
    }
  }

  // Info popup for if the Account creation fails
  AVMEPopupInfo {
    id: accountFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on Account creation. Please try again."
  }
}
