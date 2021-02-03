import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

Item {
  id: new_account_screen

  AVMEMenu {
    id: sideMenu
    width: 200
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
    }
  }

  Column {
    id: items
    anchors {
      left: sideMenu.right
      right: parent.right
      top: parent.top
      bottom: parent.bottom
    }
    spacing: 30
    topPadding: 50

    Text {
      id: info
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Enter the following details to create a new Account."
    }

    Row {
      id: account_name_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: account_name_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Name:"
      }
      TextField {
        id: account_name_input
        width: items.width / 2
        selectByMouse: true
        placeholderText: "(Optional) Enter a name for your Account"
      }
    }

    Row {
      id: account_pass_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: account_pass_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Passphrase:"
      }
      TextField {
        id: account_pass_input
        width: items.width / 2
        selectByMouse: true
        echoMode: TextInput.Password
        passwordCharacter: "*"
        placeholderText: "Enter a passphrase to protect your Account"
      }
    }

    Row {
      id: account_hint_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: account_hint_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Hint:"
      }
      TextField {
        id: account_hint_input
        width: items.width / 2
        selectByMouse: true
        placeholderText: "(Optional) Enter a hint to help you remember the passphrase"
      }
    }

    Row {
      id: account_pass_check_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      CheckBox {
        id: account_pass_check
        text: "Use wallet passphrase"
        onClicked: {
          account_pass_input.enabled = !account_pass_input.enabled
          account_hint_input.enabled = !account_hint_input.enabled
        }
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
        onClicked: System.setScreen(content, "qml/screens/AccountsScreen.qml")
      }

      AVMEButton {
        id: btn_done
        height: 60
        width: items.width / 8
        text: "Done"
        onClicked: {
          var accountName = account_name_input.text
          var accountPass = account_pass_input.text
          var accountHint = account_hint_input.text
          var accountPassCheck = account_pass_check.checked
          if (accountPassCheck) {
            accountPass = System.getWalletPass()
            accountHint = ""
          }
          try {
            System.createNewAccount(accountName, accountPass, accountHint, accountPassCheck)
            console.log("Account created successfully")
            System.setScreen(content, "qml/screens/AccountsScreen.qml")
          } catch (error) {
            // TODO: show this message on screen with a label
            // Also I think this actually doesn't work but I haven't tested
            print ("Error on account creation.")
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
