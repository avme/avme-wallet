/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for confirming a transaction with user input.
AVMEPopup {
  id: confirmTxPopup
  widthPct: 0.6
  heightPct: 0.6
  property alias info: summaryInfo.text
  property alias pass: passInput.text
  property alias passFocus: passInput.focus
  property alias timer: infoTimer
  property alias okBtn: btnOk
  property bool isSameAddress: false
  onAboutToShow: passInput.focus = true
  onAboutToHide: confirmTxPopup.clean()

  function clean() {
    passInput.text = ""
  }

  Column {
    anchors.centerIn: parent
    spacing: 20

    Text {
      id: warningText
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
      id: summaryInfo
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
    }

    Text {
      id: passInfo
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
      width: confirmTxPopup.width / 2
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
        onClicked: confirmTxPopup.close()
      }
      AVMEButton {
        id: btnOk
        text: "OK"
        enabled: (passInput.text !== "")
      }
    }
  }
}
