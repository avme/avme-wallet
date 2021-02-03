import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

Item {
  id: transaction_screen

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
      text: "Enter the following details to send a transaction."
    }

    Row {
      id: sender_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: sender_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "From:"
      }
      TextField {
        id: sender_input
        width: items.width / 2
        readOnly: true
        text: System.getTxSenderAccount()
      }
    }

    Text {
      id: sender_amount
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Total: " + System.getTxSenderAmount() + " ETH" // TODO: change according to token
    }

    Row {
      id: receiver_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: receiver_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "To:"
      }
      TextField {
        id: receiver_input
        width: items.width / 2
        selectByMouse: true
        placeholderText: "Receiving address (e.g. 0x123456789ABCDEF...)"
      }
    }

    Row {
      id: amount_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: amount_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Amount:"
      }
      TextField {
        id: amount_input
        width: items.width / 4
        selectByMouse: true
        placeholderText: "Fixed point amount (e.g. 0.5)"
      }
      Text {
        id: amount_label
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignLeft
        text: "ETH" // TODO: change according to token
      }
    }

    Row {
      id: gaslimit_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: gaslimit_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Gas Limit:"
      }
      TextField {
        id: gaslimit_input
        width: items.width / 4
        selectByMouse: true
        text: "21000" // TODO: change according to token
        placeholderText: "Recommended: 21000"
        enabled: !autofees_check.checked
      }
      Text {
        id: gaslimit_label
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignLeft
        text: "Wei"
      }
    }

    Row {
      id: gasprice_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: gasprice_text
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Gas Price:"
      }
      TextField {
        id: gasprice_input
        width: items.width / 4
        selectByMouse: true
        text: ""
        Component.onCompleted: {
          gasprice_input.text = System.getAutomaticFee()
        }
        placeholderText: "Recommended: 50"
        enabled: !autofees_check.checked
      }
      Text {
        id: gasprice_label
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignLeft
        text: "Gwei"
      }
    }

    Row {
      id: autofees_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      CheckBox {
        id: autofees_check
        property string prev_limit
        property string prev_price
        text: "Use automatic fees"
        checked: true
        onClicked: {
          if (!gaslimit_input.enabled && !gasprice_input.enabled) {
            gaslimit_input.text = prev_limit
            gasprice_input.text = prev_price
            prev_limit = ""
            prev_price = ""
          } else {
            prev_limit = gaslimit_input.text
            prev_price = gasprice_input.text
            gaslimit_input.text = ""
            gasprice_input.text = ""
          }
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
        onClicked: confirm_popup.open()
      }
    }
  }

  Popup {
    id: confirm_popup
    width: parent.width / 2
    height: parent.height / 2
    x: (parent.width / 2) - (width / 2)
    y: (parent.height / 2) - (height / 2)
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnPressOutside

    // TODO: maybe put a warning icon here
    Rectangle {
      id: popup_bg
      anchors.fill: parent
      color: "#9A4FAD"
      Text {
        id: popup_text
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: parent.top
          topMargin: parent.height / 8
        }
        horizontalAlignment: Text.AlignHCenter
        text: "You will send <b>" + amount_input.text + " " + amount_label.text
        + "</b> from the address<br><b>" + sender_input.text + "</b>"
        + "<br>to the address<br><b>" + receiver_input.text + "</b>"
        + "<br>Gas Limit: <b>" + gaslimit_input.text + " Wei</b>"
        + "<br>Gas Price: <b>" + gasprice_input.text + " Gwei</b>"
      }

      Text {
        id: popup_passphrase_text
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: popup_text.bottom
          topMargin: 30
        }
        horizontalAlignment: Text.AlignHCenter
        text: (!popup_passphrase_timer.running) ?
        "Enter your wallet's passphrase to confirm the transaction." :
        "Wrong passphrase, please try again."

        Timer {
          id: popup_passphrase_timer
          interval: 2000
        }
      }

      Row {
        id: passphrase_row
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        anchors {
          top: popup_passphrase_text.bottom
          bottom: popup_buttons.top
          topMargin: 10
        }
        TextField {
          id: passphrase_input
          width: items.width / 4
          selectByMouse: true
          echoMode: TextInput.Password
          passwordCharacter: "*"
        }
      }

      Row {
        id: popup_buttons
        anchors {
          horizontalCenter: parent.horizontalCenter
          bottom: parent.bottom
          bottomMargin: parent.height / 8
        }
        spacing: 10

        AVMEButton {
          id: btn_no
          text: "Cancel"
          onClicked: confirm_popup.close()
        }
        AVMEButton {
          id: btn_yes
          text: "Done"
          onClicked: {
            if (System.checkWalletPass(passphrase_input.text)) {
              System.setTxSenderAccount(sender_input.text)
              System.setTxReceiverAccount(receiver_input.text)
              System.setTxAmount(amount_input.text)
              System.setTxLabel(amount_label.text)
              System.setTxGasLimit(gaslimit_input.text)
              System.setTxGasPrice(gasprice_input.text)
              System.setScreen(content, "qml/screens/ProgressScreen.qml")
              confirm_popup.close()
            } else {
              popup_passphrase_timer.start()
            }
          }
        }
      }
    }
  }
}
