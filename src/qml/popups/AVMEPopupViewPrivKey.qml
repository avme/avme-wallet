/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for viewing an Account's private key. Has to be opened manually.
AVMEPopup {
  id: viewPrivKeyPopup
  readonly property alias pass: keyPassInput.text
  property alias showBtn: btnShow
  property color popupBgColor: "#1C2029"
  property color popupKeyBgColor: "#2D3542"
  property color popupSelectionColor: "#58A0B9"

  onAboutToShow: {
    btnCopy.enabled = false
    keyPassInput.forceActiveFocus()
  }
  onAboutToHide: viewPrivKeyPopup.clean()

  function showPrivKey() {
    if (keyText.timer.running) { keyText.timer.stop() }
    keyText.text = qmlSystem.getPrivateKeys(accountHeader.currentAddress, keyPassInput.text)
    btnCopy.enabled = true
  }

  function showErrorMsg() {
    keyText.text = "Wrong passphrase, please try again"
    keyText.timer.start()
    btnCopy.enabled = false
  }

  function clean() {
    keyPassInput.text = ""
    keyText.text = ""
    btnCopy.enabled = false
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

    // Enter/Numpad enter key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnShow.enabled) { btnShow.checkPass() }
      }
    }

    Text {
      id: warningText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Please authenticate to view the private key for the Account:<br>"
      + "<b>" + accountHeader.currentAddress + "</b>"
      + "<br><br><b>YOU ARE FULLY RESPONSIBLE FOR GUARDING YOUR PRIVATE KEYS."
      + "<br>KEEP THEM AWAY FROM PRYING EYES AND DO NOT SHARE THEM WITH ANYONE."
      + "<br>WE ARE NOT HELD LIABLE FOR ANY POTENTIAL FUND LOSSES CAUSED BY THIS."
      + "<br>PROCEED AT YOUR OWN RISK.</b>"
    }

    AVMEInput {
      id: keyPassInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 3
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    TextArea {
      id: keyText
      property alias timer: keyTextTimer
      width: (parent.width * 0.9)
      height: 50
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      readOnly: true
      selectByMouse: true
      selectionColor: popupSelectionColor
      color: "#FFFFFF"
      font.pixelSize: 14.0
      background: Rectangle {
        width: parent.width
        height: parent.height
        color: popupKeyBgColor
        radius: 10
      }
      Timer { id: keyTextTimer; interval: 2000; onTriggered: keyText.text = "" }
    }

    Row {
      id: btnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnClose
        text: "Close"
        onClicked: viewPrivKeyPopup.close()
      }
      AVMEButton {
        id: btnCopy
        text: (!copyTimer.running) ? "Copy" : "Copied!"
        Timer { id: copyTimer; interval: 2000 }
        onClicked: {
          qmlSystem.copyToClipboard(keyText.text)
          copyTimer.start()
        }
      }
      AVMEButton {
        id: btnShow
        text: "Show"
        enabled: (keyPassInput.text !== "")
        onClicked: checkPass()
        function checkPass() {
          if (qmlSystem.checkWalletPass(pass)) {
            showPrivKey()
          } else {
            showErrorMsg()
          }
        }
      }
    }
  }
}
