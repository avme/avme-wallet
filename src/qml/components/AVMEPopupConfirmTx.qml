/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Popup for confirming a coin/token transaction. Has to be opened manually.
 * Has the following items:
 * - "amount": the amount that will be sent
 * - "amountLabel" the coin/token label
 * - "sender": the Account that will send a transaction
 * - "receiver": the Account that will receive the transaction
 * - "gasLimit": self-explanatory
 * - "gasPrice": self-explanatory
 * - "pass": the Wallet password input
 * - "confirmBtn.onClicked": what to do when confirming the action
 * - "setTxData(amount, label, from, to, gasLimit, gasPrice)": set tx data for display
 * - "showErrorMsg()": self-explanatory
 * - "clean()": helper function to clean up inputs/data
 */

Popup {
  id: confirmTxPopup
  property string amount
  property string label
  property string from
  property string to
  property string gasLimit
  property string gasPrice
  property alias pass: passInput.text
  property alias confirmBtn: btnConfirm

  function setTxData(amount, label, from, to, gasLimit, gasPrice) {
    confirmTxPopup.amount = amount
    confirmTxPopup.label = label
    confirmTxPopup.from = from
    confirmTxPopup.to = to
    confirmTxPopup.gasLimit = gasLimit
    confirmTxPopup.gasPrice = gasPrice
  }

  function showErrorMsg() {
    passTextTimer.start()
  }

  function clean() {
    amount = label = from = to = gasLimit = gasPrice = passInput.text = ""
  }

  width: window.width / 2
  height: window.height / 2
  x: (window.width / 2) - (width / 2)
  y: (window.height / 2) - (height / 2)
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose

  Rectangle {
    anchors.fill: parent
    color: "#9A4FAD"

    // Transaction summary
    Text {
      id: infoText
      anchors {
        horizontalCenter: parent.horizontalCenter
        top: parent.top
        topMargin: parent.height / 8
      }
      horizontalAlignment: Text.AlignHCenter
      text: "You will send <b>" + amount + " " + label
      + "</b> from the address<br><b>" + from + "</b>"
      + "<br>to the address<br><b>" + to + "</b>"
      + "<br>Gas Limit: <b>" + gasLimit + " Wei</b>"
      + "<br>Gas Price: <b>" + gasPrice + " Gwei</b>"
    }

    // Passphrase status text ("enter your pass", or "wrong pass")
    Text {
      id: passText
      anchors {
        horizontalCenter: parent.horizontalCenter
        top: infoText.bottom
        topMargin: 15
      }
      horizontalAlignment: Text.AlignHCenter
      Timer { id: passTextTimer; interval: 2000 }
      text: (!passTextTimer.running)
      ? "Please authenticate to confirm the transaction."
      : "Wrong passphrase, please try again"
    }

    // Passphrase input
    AVMEInput {
      id: passInput
      width: items.width / 4
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
      anchors {
        horizontalCenter: parent.horizontalCenter
        top: passText.bottom
        topMargin: 25
      }
    }

    // Buttons
    Row {
      id: btnRow
      anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
        bottomMargin: parent.height / 8
      }
      spacing: 10

      AVMEButton {
        id: btnCancel
        text: "Cancel"
        onClicked: {
          confirmTxPopup.clean()
          confirmTxPopup.close()
        }
      }
      AVMEButton {
        id: btnConfirm
        text: "Confirm"
        enabled: (passInput.text != "")
      }
    }
  }
}
