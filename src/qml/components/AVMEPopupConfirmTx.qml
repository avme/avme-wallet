/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// Popup for confirming a transaction with user input.
Popup {
  id: confirmTxPopup
  property alias pass: passInput.text
  property alias timer: infoTimer
  property alias okBtn: btnOk
  property bool isSameAddress: false
  property color popupBgColor: "#1C2029"

  width: parent.width * ((isSameAddress) ? 0.6 : 0.5)
  height: parent.height * ((isSameAddress) ? 0.4 : 0.3)
  x: (parent.width * ((isSameAddress) ? 0.4 : 0.5)) / 2
  y: (parent.height * ((isSameAddress) ? 0.6 : 0.7)) / 2
  background: Rectangle { anchors.fill: parent; color: popupBgColor; radius: 10 }
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose

  function clean() {
    passInput.text = ""
  }

  Column {
    anchors.fill: parent
    spacing: 30
    topPadding: 30

    Text {
      id: warning
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.bold: true
      font.pixelSize: 14.0
      visible: (isSameAddress)
      text: "ATTENTION: receiver Account is the exact same as the sender.<br>"
      + "If this is not what you want, go back now and set another Account as the receiver."
    }

    Text {
      id: info
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: (!infoTimer.running)
      ? "Please authenticate to confirm this transaction."
      : "Wrong passphrase, please try again."
      Timer { id: infoTimer; interval: 2000 }
    }

    AVMEInput {
      id: passInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 2
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    Row {
      id: btnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnBack
        text: "Back"
        onClicked: {
          confirmTxPopup.clean()
          confirmTxPopup.close()
        }
      }
      AVMEButton {
        id: btnOk
        text: "OK"
        enabled: (passInput.text !== "")
      }
    }
  }
}
