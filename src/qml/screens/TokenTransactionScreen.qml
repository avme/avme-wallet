import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for making a transaction with the selected Account

Item {
  id: tokenTransactionScreen

  function updateTxCost() {
    txCost.text = "Transaction Cost: "
    + System.calculateTransactionCost("0", gasLimitInput.text, gasPriceInput.text)
    + " " + System.getCurrentCoin()
  }

  Component.onCompleted: {
    fetchFeesPopup.open()
    gasPriceInput.text = System.getAutomaticFee()
    updateTxCost()
    fetchFeesPopup.close()
  }

  Column {
    id: items
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      bottom: parent.bottom
    }
    spacing: 40
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

      AVMEInput {
        id: senderInput
        width: items.width / 2
        readOnly: true
        validator: RegExpValidator { regExp: /0x[0-9a-fA-F]{40}/ }
        label: "Sender Address"
        text: System.getTxSenderAccount()
      }
    }

    // Sender total amount (display)
    Text {
      id: senderAmount
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Sender Total: "
      + System.getTxSenderTokenAmount() + " " + System.getCurrentToken() + " / "
      + System.getTxSenderCoinAmount() + " " + System.getCurrentCoin()
    }

    // Receiver Account
    Row {
      id: receiverRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: receiverInput
        width: items.width / 2
        validator: RegExpValidator { regExp: /0x[0-9a-fA-F]{40}/ }
        label: "Receiver Address"
        placeholder: "e.g. 0x123456789ABCDEF..."
      }
    }

    // Amount that will be sent
    Row {
      id: amountRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: amountInput
        width: items.width / 2
        validator: RegExpValidator { regExp: System.createTokenRegExp() }
        label: "Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        Text {
          id: amountLabel
          anchors.left: parent.right
          anchors.leftMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          text: System.getCurrentToken()
        }
        onTextEdited: updateTxCost()
      }
    }

    // Gas Limit and Gas Price
    Row {
      id: gasLimitRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: gasLimitInput
        width: items.width / 4
        label: "Gas Limit (Wei)"
        validator: RegExpValidator { regExp: /[0-9]+/ }
        text: "80000"
        enabled: !autoFeesCheck.checked
        onTextEdited: updateTxCost()
      }
      AVMEInput {
        id: gasPriceInput
        width: items.width / 4
        label: "Gas Price (Gwei)"
        validator: RegExpValidator { regExp: /[0-9]+/ }
        enabled: !autoFeesCheck.checked
        onTextEdited: updateTxCost()
      }
    }

    // Transaction total cost (display)
    Text {
      id: txCost
      anchors.horizontalCenter: parent.horizontalCenter
      text: updateTxCost()
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
            // Disabled fields (auto fees on)
            gasLimitInput.text = prevLimit
            gasPriceInput.text = prevPrice
            prevLimit = ""
            prevPrice = ""
          } else {
            // Enabled fields (auto fees off)
            prevLimit = gasLimitInput.text
            prevPrice = gasPriceInput.text
            gasLimitInput.text = ""
            gasPriceInput.text = ""
          }
          updateTxCost()
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
        enabled: {
          var senderOK = senderInput.acceptableInput
          var receiverOK = receiverInput.acceptableInput
          var amountOK = amountInput.acceptableInput
          var gasLimitOK = gasLimitInput.acceptableInput
          var gasPriceOK = gasPriceInput.acceptableInput
          enabled: (senderOK && receiverOK && amountOK && gasLimitOK && gasPriceOK)
        }
        onClicked: {
          var noCoinFunds = System.hasInsufficientCoinFunds(
            System.getTxSenderCoinAmount(),
            System.calculateTransactionCost("0", gasLimitInput.text, gasPriceInput.text)
          )
          var noTokenFunds = System.hasInsufficientTokenFunds(
            System.getTxSenderTokenAmount(), amountInput.text
          )
          if (noCoinFunds || noTokenFunds) {
            fundsPopup.open()
          } else {
            confirmTxPopup.setTxData(
              amountInput.text, amountLabel.text, senderInput.text,
              receiverInput.text, gasLimitInput.text, gasPriceInput.text
            )
            confirmTxPopup.open()
          }
        }
      }
    }
  }

  // Popup for fetching network fees
  AVMEPopup {
    id: fetchFeesPopup
    info: "Requesting optimal fees..."
  }

  // Popup for warning about insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your transaction values."
  }

  // Popup for confirming the transaction
  AVMEPopupConfirmTx {
    id: confirmTxPopup
    confirmBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        System.setTxReceiverAccount(to)
        System.setTxReceiverTokenAmount(amount)
        System.setTxGasLimit(gasLimit)
        System.setTxGasPrice(gasPrice)
        confirmTxPopup.close()
        System.setScreen(content, "qml/screens/ProgressScreen.qml")
        System.txStart(pass)
      } else {
        confirmTxPopup.showErrorMsg()
      }
    }
  }
}
