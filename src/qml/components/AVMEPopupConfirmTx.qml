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
  height: (isSameAddress) ? 280 : 220
  x: (parent.width * ((isSameAddress) ? 0.4 : 0.5)) / 2
  //y: (parent.height * ((isSameAddress) ? 0.6 : 0.7)) / 2
  y: (parent.height * 0.5) - (height / 2)
  background: Rectangle { anchors.fill: parent; color: popupBgColor; radius: 10 }
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose

  function clean() {
    passInput.text = ""
  }

  Text {
    id: warning
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      topMargin: 20
    }
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
    anchors {
      top: (isSameAddress) ? warning.bottom : parent.top
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
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
    anchors {
      bottom: btnRow.top
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    width: parent.width / 2
    echoMode: TextInput.Password
    passwordCharacter: "*"
    label: "Passphrase"
    placeholder: "Your Wallet's passphrase"
  }

  Row {
    id: btnRow
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 20
    }
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
