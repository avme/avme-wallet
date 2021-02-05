import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for making a transaction with the selected Account

Item {
  id: transactionScreen

  Component.onCompleted: {
    fetchFeesPopup.open()
    gasPriceInput.text = System.getAutomaticFee()
    fetchFeesPopup.close()
  }

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
    spacing: 30
    topPadding: 50

    Text {
      id: info
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Enter the following details to send a transaction."
    }

    // Sender Account (pre-selected)
    Row {
      id: senderRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: senderText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "From:"
      }
      TextField {
        id: senderInput
        width: items.width / 2
        readOnly: true
        text: System.getTxSenderAccount()
      }
    }

    // Sender total amount (display)
    // TODO: check for insufficient funds
    Text {
      id: senderAmount
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Total: " + System.getTxSenderAmount() + " ETH" // TODO: change according to token
    }

    // Receiver Account
    Row {
      id: receiverRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: receiverText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "To:"
      }
      TextField {
        id: receiverInput
        width: items.width / 2
        selectByMouse: true
        placeholderText: "Receiving address (e.g. 0x123456789ABCDEF...)"
      }
    }

    // Amount that will be sent
    Row {
      id: amountRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: amountText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Amount:"
      }
      TextField {
        id: amountInput
        width: items.width / 4
        selectByMouse: true
        placeholderText: "Fixed point amount (e.g. 0.5)"
      }
      Text {
        id: amountLabel
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignLeft
        text: "ETH" // TODO: change according to token
      }
    }

    // Gas Limit
    Row {
      id: gasLimitRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: gasLimitText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Gas Limit:"
      }
      TextField {
        id: gasLimitInput
        width: items.width / 4
        selectByMouse: true
        text: "21000" // TODO: change according to token
        placeholderText: "Recommended: 21000"
        enabled: !autoFeesCheck.checked
      }
      Text {
        id: gasLimitLabel
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignLeft
        text: "Wei"
      }
    }

    // Gas Price
    Row {
      id: gasPriceRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: gasPriceText
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignRight
        text: "Gas Price:"
      }
      TextField {
        id: gasPriceInput
        width: items.width / 4
        selectByMouse: true
        text: ""
        placeholderText: "Recommended: 50"
        enabled: !autoFeesCheck.checked
      }
      Text {
        id: gasPriceLabel
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        horizontalAlignment: Text.AlignLeft
        text: "Gwei"
      }
    }

    // Checkbox for using automatic fees from the network
    Row {
      id: autoFeesRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      CheckBox {
        id: autoFeesCheck
        property string prevLimit
        property string prevPrice
        text: "Use automatic fees"
        checked: true
        onClicked: {
          if (!gasLimitInput.enabled && !gasPriceInput.enabled) {
            gasLimitInput.text = prevLimit
            gasPriceInput.text = prevPrice
            prevLimit = ""
            prevPrice = ""
          } else {
            prevLimit = gasLimitInput.text
            prevPrice = gasPriceInput.text
            gasLimitInput.text = ""
            gasPriceInput.text = ""
          }
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
        onClicked: confirmPopup.open()
      }
    }
  }

  // Popup for fetching network fees
  Popup {
    id: fetchFeesPopup
    width: window.width / 4
    height: window.height / 8
    x: (window.width / 2) - (width / 2)
    y: (window.height / 2) - (height / 2)
    modal: true
    focus: true
    padding: 0  // Remove white borders
    closePolicy: Popup.NoAutoClose

    Rectangle {
      anchors.fill: parent
      color: "#9A4FAD"
      Text {
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        text: "Requesting optimal fees..."
      }
    }
  }

  // Popup for confirming the transaction
  Popup {
    id: confirmPopup
    width: window.width / 2
    height: window.height / 2
    x: (window.width / 2) - (width / 2)
    y: (window.height / 2) - (height / 2)
    modal: true
    focus: true
    padding: 0  // Remove white borders
    closePolicy: Popup.CloseOnPressOutside

    Rectangle {
      id: popupBg
      anchors.fill: parent
      color: "#9A4FAD"

      // Transaction summary
      Text {
        id: popupText
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: parent.top
          topMargin: parent.height / 8
        }
        horizontalAlignment: Text.AlignHCenter
        text: "You will send <b>" + amountInput.text + " " + amountLabel.text
        + "</b> from the address<br><b>" + senderInput.text + "</b>"
        + "<br>to the address<br><b>" + receiverInput.text + "</b>"
        + "<br>Gas Limit: <b>" + gasLimitInput.text + " Wei</b>"
        + "<br>Gas Price: <b>" + gasPriceInput.text + " Gwei</b>"
      }

      // Passphrase status text ("enter your pass", or "wrong pass")
      Text {
        id: popupPassText
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: popupText.bottom
          topMargin: 30
        }
        horizontalAlignment: Text.AlignHCenter
        text: (!popupPassTimer.running) ?
        "Enter your wallet's passphrase to confirm the transaction." :
        "Wrong passphrase, please try again."

        Timer {
          id: popupPassTimer
          interval: 2000
        }
      }

      // Passphrase input
      TextField {
        id: passInput
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: popupPassText.bottom
          topMargin: 10
        }
        width: items.width / 4
        selectByMouse: true
        echoMode: TextInput.Password
        passwordCharacter: "*"
      }

      // Buttons
      Row {
        id: popupBtns
        anchors {
          horizontalCenter: parent.horizontalCenter
          bottom: parent.bottom
          bottomMargin: parent.height / 8
        }
        spacing: 10

        AVMEButton {
          id: btnCancel
          text: "Cancel"
          onClicked: confirmPopup.close()
        }
        AVMEButton {
          id: btnConfirm
          text: "Confirm"
          onClicked: {
            if (System.checkWalletPass(passInput.text)) {
              System.setTxSenderAccount(senderInput.text)
              System.setTxReceiverAccount(receiverInput.text)
              System.setTxAmount(amountInput.text)
              System.setTxLabel(amountLabel.text)
              System.setTxGasLimit(gasLimitInput.text)
              System.setTxGasPrice(gasPriceInput.text)
              confirmPopup.close()
              System.setScreen(content, "qml/screens/ProgressScreen.qml")
            } else {
              popupPassTimer.start()
            }
          }
        }
      }
    }
  }
}
