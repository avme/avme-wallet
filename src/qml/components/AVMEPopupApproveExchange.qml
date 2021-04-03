import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Popup for approving token exchange. Has to be opened manually.
 * Has the following items:
 * - "gasLimit": self-explanatory
 * - "gasPrice": self-explanatory
 * - "pass": the Wallet password input
 * - "confirmBtn.onClicked": what to do when confirming the action
 * - "setTxData(gasLimit, gasPrice)": set tx data for display
 * - "showErrorMsg()": self-explanatory
 * - "clean()": helper function to clean up inputs/data
 */

Popup {
  id: approveExchangePopup
  property string gasLimit
  property string gasPrice
  property alias pass: passInput.text
  property alias confirmBtn: btnConfirm

  function setTxData(gasLimit, gasPrice) {
    approveExchangePopup.gasLimit = gasLimit
    approveExchangePopup.gasPrice = gasPrice
  }

  function showErrorMsg() {
    passTextTimer.start()
  }

  function clean() {
    gasLimit = gasPrice = passInput.text = ""
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
      text: "In order to exchange the desired token," + "<br>"
      + "you must first give approval from this Account."
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
      ? "Please authenticate to confirm the approval."
      : "Wrong passphrase, please try again"
    }

    // Passphrase input
    AVMEInput {
      id: passInput
      width: parent.width / 2
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
          approveExchangePopup.clean()
          approveExchangePopup.close()
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